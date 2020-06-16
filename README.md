# demo-az-apim-storage

This project shows how to use API Managment to expose private blobs from Azure storage via HTTP 

##  Blob storage

Create a storage account and create a container with your content.

##  API Managment 

### 1. Create and API Manamgent Instance
### 2. Create an API
### 3. Use an API policy to access storage account as a backend.


Select a reference policy base on the API Managment SKU:
- https://github.com/ncrtc/demo-az-apim-storage/blob/master/policy-consumption.xml
- https://github.com/ncrtc/demo-az-apim-storage/blob/master/policy-standard.xml

The consumpption SKU has different headers that are sent to the backend and needs slighly different signing logic.

In the selected policy replace the three placeholders:
 - YOUR_STORAGE_ACCOUNT_NAME_HERE
 - YOUR_STORAGE_CONTAINER_NAME_HERE
 - YOUR_STORAGE_ACCESS_KEY_HERE


### Reference
- https://docs.microsoft.com/en-us/rest/api/storageservices/get-blob
