[cmdletbinding()]
param(
    $name,
    $location = 'eastus',
    $org = 'test',
    $email = 'tim@contoso.com'
)

$rgName = "rg-" + $name

try {
    Get-AzureRmResourceGroup -Name $rgName -ErrorAction Stop
} catch {
    New-AzResourceGroup -Name $rgName -Location $location
}

$storName = "stor" + $name
$containerName = "apimblobs"
Add-Content "test.txt" -Value "Hello World"
New-AzStorageAccount -ResourceGroupName $rgname -Name $storName -location $location -skuname Standard_GRS
$storKey = Get-AzStorageAccountKey -name $storName -ResourceGroupName $rgName | select -First 1 -ExpandProperty Value

$storContext = New-AzStorageContext -StorageAccountName $storName -StorageAccountKey $storKey
New-AzStorageContainer -Name $containerName -Context $storContext
Set-AzStorageBlobContent -Container $containerName -File ".\test.txt" -Blob "test.txt"  -Context $storContext

$apimName = "apim-" + $name
$apiName = "blob"
$Policy = (Invoke-WebRequest https://raw.githubusercontent.com/ncrtc/demo-az-apim-storage/master/policy-standard.xml).content.Replace("YOUR_STORAGE_ACCOUNT_NAME_HERE","$storName").Replace("YOUR_STORAGE_CONTAINER_NAME_HERE","$containerName").Replace("YOUR_STORAGE_ACCESS_KEY_HERE","$storKey")
New-AzAPiManagement -ResourceGroupName $rgname -Name $apimName -location $location -organization $org -adminemail $email -Sku Consumption

$ApiMgmtContext = New-AzApiManagementContext -ResourceGroupName $rgName -ServiceName $apimName
$apiId = (New-AzApiManagementApi -Context $ApiMgmtContext -Name $apiName -Protocols @("https") -Path "blob" -serviceurl "https://api.contoso.com").apiId
New-AzAPiManagementOperation -Context $ApiMgmtContext -ApiId $apiId -OperationId "get" -Name "GET" -method "GET" -UrlTemplate "/*"

Set-Content -Path "policy.xml" -Value $Policy
Set-AzApiManagementPolicy -Context $ApiMgmtContext -apiid $apiId -PolicyFilePath "policy.xml"
