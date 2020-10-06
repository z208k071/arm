# Windows 10 Enterprise for Virtual Desktop 2004

## 目的
Azure Image Builder を使用して、日本語化された Windows 10 Enterprise for Virtual Desktop 2004 イメージを自動生成する。

## リソースグループ作成
Azure Image Builder による展開

```
# 現在のコンテキストを取得
$currentAzContext = Get-AzContext

# 変数の定義
## Image Builder でイメージをデプロイするリソースグループの名前
$rgName = "AIB-Deploy-RG"
## リソースグループのリージョン
$rgLocation = "japaneast"

## Image Builder を実行するリージョン
## (East US. East US 2, West Central US, West US, West US 2, North Europe, West Europe)
$aibLocation="westus"

## 現在のサブスクリプション ID を取得
$subscriptionID = $currentAzContext.Subscription.Id

# リソースグループの作成
New-AzResourceGroup -Name $rgName -Location $rgLocation
```

## Azure Image Builder 用のマネージド ID とロールを作成
Image Builder で自動的に仮想マシン作成からイメージの作成まで行えるように、
サービスで使う資格情報と、必要な権限を提議したカスタムロールを作成します。

```
# モジュールのインポート
Install-Module -Name Az.ManagedServiceIdentity
Import-Module -Name Az.ManagedServiceIdentity

# マネージド ID の作成
$idenityName = "aibIdentityPreview"
New-AzUserAssignedIdentity -ResourceGroupName $rgName -Name $idenityName
## マネージド ID のリソース ID
$idenityNameResourceId = $(Get-AzUserAssignedIdentity -ResourceGroupName $rgName -Name $idenityName).Id
## マネージド ID のプリンシパル ID
$idenityNamePrincipalId = $(Get-AzUserAssignedIdentity -ResourceGroupName $rgName -Name $idenityName).PrincipalId

# AIB 用のカスタムロールを作成
$imageRoleDefName = "Azure Image Builder Image Def Preview"
## カスタムロール用テンプレートのダウンロードパスを定義
$aibRoleImageCreationUrl = "https://raw.githubusercontent.com/sny0421/Azure-Image-Builder-Japanese/master/AIB_Rolle_Define/aib-role-creation.json"
$aibRoleImageCreationPath = "aib-role-reation.json"
## カスタムロール用テンプレートをダウンロード
Invoke-WebRequest -Uri $aibRoleImageCreationUrl -OutFile $aibRoleImageCreationPath -UseBasicParsing

## カスタムロール用テンプレート内の変数を置換
((Get-Content -path $aibRoleImageCreationPath -Raw) -replace '<imageRoleDefName>', $imageRoleDefName) | Set-Content -Path $aibRoleImageCreationPath
((Get-Content -path $aibRoleImageCreationPath -Raw) -replace '<subscriptionID>',$subscriptionID) | Set-Content -Path $aibRoleImageCreationPath
((Get-Content -path $aibRoleImageCreationPath -Raw) -replace '<rgName>', $rgName) | Set-Content -Path $aibRoleImageCreationPath

## カスタムロールを作成
New-AzRoleDefinition -InputFile $aibRoleImageCreationPath

## マネージド ID でリソースグループを操作できるようカスタムロールを割り当て
New-AzRoleAssignment -ObjectId $idenityNamePrincipalId -RoleDefinitionName $imageRoleDefName -Scope "/subscriptions/$subscriptionID/resourceGroups/$rgName"
```

## 共有イメージギャラリーの作成
カスタムイメージを保存する共有イメージギャラリーを作成します。

```
# 変数の定義
## 共有イメージギャラリーの名前
$galleryName= "MyAibSig001"
## イメージ定義の名前
$imageName ="Windows-10-EVD-2004-JP"
## レプリカするリージョンの指定
$replicaLocation = "japaneast"

# 共有ギャラリーの作成
New-AzGallery -GalleryName $galleryName -ResourceGroupName $rgName -Location $aibLocation

# イメージ定義の作成
New-AzGalleryImageDefinition -GalleryName $galleryName -ResourceGroupName $rgName -Location $aibLocation -Name $imageName -OsState generalized -OsType Windows -Publisher 'AIB' -Offer 'Windows' -Sku 'Windows_10_EVD_2004'
```

## Azure Image Builder によるテンプレートからのイメージ作成

```
# Image Builder に登録するイメージテンプレートの名前
$imageTemplateName = "AIB-Windows-10-EVD-2004-Japanese-Template"

# イメージテンプレートの作成
## イメージテンプレートのダウンロード URL を定義
$templateUrl="https://raw.githubusercontent.com/sny0421/Azure-Image-Builder-Japanese/master/Windows_10_EVD_2004/image-build-template.json"
$templateFilePath = "image-build-template.json"
## イメージテンプレートをダウンロード
Invoke-WebRequest -Uri $templateUrl -OutFile $templateFilePath -UseBasicParsing

# イメージテンプレートのデプロイ
New-AzResourceGroupDeployment -ResourceGroupName $rgName -TemplateFile $templateFilePath -api-version "2019-05-01-preview" -imageTemplateName $imageTemplateName -aibLocation $aibLocation -aibManagedId $idenityName -imageGalleryName $galleryName -imageName $imageName -replicaLocation $replicaLocation

# イメージテンプレートからのイメージ作成実行
Invoke-AzResourceAction -ResourceName $imageTemplateName -ResourceGroupName $rgName -ResourceType Microsoft.VirtualMachineImages/imageTemplates -ApiVersion "2019-05-01-preview" -Action Run -Force
```

### イメージ展開状況の確認

```
# インスタンスのプロファイルを取得
$azureRmProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
$profileClient = New-Object Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient($azureRmProfile)
Write-Verbose ("Tenant: {0}" -f  $currentAzContext.Subscription.Name)

# トークンの取得
$token = $profileClient.AcquireAccessToken($currentAzContext.Tenant.TenantId)
$accessToken = $token.AccessToken
$managementEp = $currentAzContext.Environment.ResourceManagerUrl

# 進行状況の取得
$urlBuildStatus = [System.String]::Format("{0}subscriptions/{1}/resourceGroups/$rgName/providers/Microsoft.VirtualMachineImages/imageTemplates/{2}?api-version=2019-05-01-preview", $managementEp, $currentAzContext.Subscription.Id,$imageTemplateName)
$buildJsonStatus = (Invoke-WebRequest -Method GET  -Uri $urlBuildStatus -UseBasicParsing -Headers  @{"Authorization"= ("Bearer " + $accessToken)} -ContentType application/json).content
$buildJsonStatus
```

## イメージから VM を作成
イメージ定義から VM を作成します。
CLI、GUI どちらでも構いませんが、手順は省略します。
