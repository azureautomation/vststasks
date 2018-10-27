# VSTS Tasks for Azure Automation
Visual Studio Team Services tasks for integrating with Azure Automation. The following capabilities are available:
* Create an account with an optional RunAs service principal
* Import runbooks and optionally start a runbook
* Import modules
* Import, compile and assign a DSC configuration

## Scenarios for using these tasks:
 
 These tasks enable the integration of Automation artifacts with a DevOps pipeline so that they can be released as part of a larger application or through approved workflows defined in Azure DevOps.
 There are currently three ways you can integrate Automation artifacts with Azure DevOps.
 * Integrate with Azure Automation source control and perform gates promoting your runbooks / configurations from a staging branch to a production branch. This is recommended where you do not need the advanced capabilities of Azure DevOps and are mainly using it as a source control system.
 * Declare all of your Automation artifacts using Azure ARM templates and then deploy these within Azure DevOps using the Azure Resource Group Deployment task. This is recommended if you are heavily invested in the ARM language and advanced Azure DevOps pipelines where you can manage everything declaratively and have procedures in place to maintain the mapping between new files and those defined in templates.
 * Use VSTS tasks as part of a build / release pipeline (this repo). This is recommended if you want to add controls and additional tasks when moving your automation from source control to the production automation account but have not invested in ARM templates or have procedures in place to ensure correct maintenance of the templates and automation files on an individual basis.

## To build this extension on your machine and upload it privately to your VSTS account:

1. Clone this GitHub repository
1. Navigate to the directory the repository was cloned into on your machine via Command Prompt
1. Download the latest version of node [here](https://nodejs.org/en/download/)
1. After installing node, close your current Command Prompt window and reopen a new window 
1. You will also need to install the 'TFS Cross Platform Command Line Interface' (tfx-cli) to package your extension. tfx-cli can be installed using npm by running 'npm i -g tfx-cli'
1. Sign in to the Visual Studio [Marketplace management portal](https://marketplace.visualstudio.com/manage)
1. If you don't already have a publisher, you will be prompted to create one. All extension live under a publisher
1. Open your extension manifest file: 'vss-extension.json' and set the value of the "publisher" field to the ID of your publisher
1. From the Command Prompt window, run 'tfx extension create'
1. Running the above command will generate a .vsix file
1. Click the '+ New extension' option and select Visual Studio Team Services
1. Click the link in the center of the Upload dialog to open a browse dialog
1. Locate the .vsix file created in the packaging step and upload it in the dialog box
1. A private version of this extension should now be uploaded to your VSTS account

## To test your private extension: 

1. From the management portal, select your newly uploaded extension from the list, right-click, and choose 'Share/Unshare'
1. Click the '+ Account button', enter the name of your account, and press enter
1. After sharing this extension with your VSTS account, you must now install it to your account
1. Right-click your extension and choose View Extension to open its details page
1. Click the 'Get it free' button to start the installation process (the account you shared the extension with should be selected)
1. Click the 'Install' button
1. Your extension should now be installed to your account and ready to use as build and release tasks

## To test individual tasks without having to publish the extension
1. Install the [Node CLI for Azure DevOps](https://github.com/Microsoft/tfs-cli) tools
2. Use the [Build Tasks](https://github.com/Microsoft/tfs-cli/blob/master/docs/buildtasks.md) to upload a specific task. Example: Change to the AzureAutomationAccount folder and run tfx build tasks upload --task-path . to upload just this task.
3. You can then make fixes if needed locally, delete the tasks id using tfx build tasks delete --task-id vststaskid and upload the specific task again.

## Using sample scripts/resources to test the extension: 

At the root of this repository, there is a folder called 'Samples' which contains a sample runbook, configuration, and some modules. The sample runbook comes with an optional parameter file that you can include in your runbook task if you'd like. The "simple" configuration comes with an optional parameter file. The "complex" configuration comes with its own optional parameter file and a mandatory configuration data file. The complex configuration sample also requires some DSC resources in order to be compiled and therefore calls the 'Import-DscResource' commandlet. This allows you to test implicitly uploading required DSC resources (modules) to your Automation Account given that you choose to provide a Storage Account in the DSC task when importing a new configuration. 

## To add more tasks to the extension: 

1. At the root of the directory in which you have cloned this repository, create a new folder for your task
1. Inside this new folder, add: a JSON file named 'task.json', the powershell script which contains your code for the task, and the 32x32 pixel png of the Azure Automation logo named 'icon.png'
1. Look at how other task.json files are written in this repository to understand how to write one for your task 
1. You will need to generate a new GUID to use for the "id" field in the task.json file
1. In the manifest file of this extension (vss-extension.json), add your task to the "contributions" field
1. Also add the folder you created for your task under the "files" field in the extension manifest file
