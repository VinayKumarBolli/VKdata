name: $(Build.BuildId).$(date:yyyyMMdd)

parameters:
  - name: environment
    displayName: "environment"
    type: string
    default: dev
    values:
      - dev
      - test

trigger:
  - main
pr: none

variables:
  - group: "VG-SHARED"
  - group: "VG-${{parameters.environment}}"


pool:
  # vmImage: "windows-2019"
  name: "SWC Self Hosted Windows 01"

stages:
  - stage: "Deploy_Databricks_Resources"
    displayName: "Deploy Databricks resources in ${{ parameters.environment }}"
    jobs:
      - deployment: "Deploy_Databricks_Resources"
        displayName: "Deploy Databricks resources in ${{ parameters.environment }}"
        environment: ${{ parameters.environment }}
        strategy:
          runOnce:
            deploy:
              steps:
                - checkout: self
                - task: TerraformInstaller@1
                  displayName: "tf install"
                  inputs:
                    terraformVersion: "1.4.0"
                - task: TerraformTaskV4@4
                  displayName: "tf init"
                  inputs:
                    provider: "azurerm"
                    command: "init"
                    # commandOptions: '-reconfigure'
                    workingDirectory: '$(System.DefaultWorkingDirectory)\${{ parameters.environment }}'
                    backendServiceArm: "XX"
                    backendAzureRmResourceGroupName: "XX"
                    backendAzureRmStorageAccountName: "XXX" #"$(storageName)"
                    backendAzureRmContainerName: "tfstate"
                    backendAzureRmKey: "${{ parameters.environment }}-terraform.tfstate"
                - task: TerraformTaskV4@4
                  displayName: "tf plan"
                  inputs:
                    provider: "azurerm"
                    command: "plan"
                    workingDirectory: '$(System.DefaultWorkingDirectory)\${{ parameters.environment }}'
                    commandOptions: "-var-file terraform.tfvars"
                    environmentServiceNameAzureRM: '$(azdoResourceConnection)'
                - task: TerraformTaskV4@4
                  displayName: "tf apply"
                  inputs:
                    provider: "azurerm"
                    command: "apply"
                    workingDirectory: '$(System.DefaultWorkingDirectory)\${{ parameters.environment }}'
                    commandOptions: ""
                    environmentServiceNameAzureRM: '$(azdoResourceConnection)'
