# PasStorage.Deployment

## Description: 
Creates, inserts and updates all data items for PAS (Currently only Azure Table Storage)

## Tech Used:
* GitHub Repo
* Azure Dev Ops Build Piplines using yml
* Azure Dev Ops Release Pipeline to SysTest which include the following tasks:
  + Bicep / ARM Template Deployment (Bicep file is contained in the Repo. Then the release pipeline creates the ARM Template using the Bicep file)  
  + Azure PowerShell Scripts to insert entities into a Azure Table Storage table
