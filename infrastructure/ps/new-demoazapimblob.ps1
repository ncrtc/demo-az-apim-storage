[cmdletbinding()]
param(
    $name,
    $location = 'eastus',
    $org = 'test',
    $email = 'tim@contoso.com'
)

$rgName = "rg-" + $name

if (!(Get-AzureRmResourceGroup -Name $rgName)) {
    New-AzResourceGroup -Name $rgName -Location $location
}

$storName = "stor" + $name
$containerName = "apimBlobs"
Add-Content "test.txt" -Value "Hello World"
New-AzStorageAccount -ResourceGroupName $rgname -Name $storName -location $location -skuname Standard_GRS

$storContext = New-AzStorageContext -StorageAccountName $storName -UseConnectedAccount
New-AzStorageContainer -Name $containerName -Context $storContext
Set-AzStorageBlobContent -Container $containerName -File ".\test.txt" -Blob "test.txt"
$storKey = Get-AzStorageAccountKey -name $storName -ResourceGroupName $rgName | select -First 1 -ExpandProperty Value

$apimName = "apim-" + $name
$apiId = "blob"
$Policy = (Invoke-WebRequest https://raw.githubusercontent.com/ncrtc/demo-az-apim-storage/master/policy-standard.xml).content.Replace("YOUR_STORAGE_ACCOUNT_NAME_HERE","$storName").Replace("YOUR_STORAGE_CONTAINER_NAME_HERE","$containerName").Replace("YOUR_STORAGE_ACCESS_KEY_HERE","$storKey")
New-AzAPiManagement -ResourceGroupName $rgname -Name $apimName -location $location -organization $org -adminemail $email -Sku Consumption -Capacity 1

$ApiMgmtContext = New-AzApiManagementContext -ResourceGroupName $rgName -ServiceName $apimName
New-AzApiManagementApi -Context $ApiMgmtContext -Name $apiId -Protocols @("https") -Path "blob"
New-AzAPiManagementOperation -Context $ApiMgmtContext -ApiId $apiId -OperationId "get" -Name "GET" -method "GET" -UrlTemplate "/*"
Set-AzApiManagementPolicy -Context $ApiMgmtContext -apiid $apiId -policy $Policy
