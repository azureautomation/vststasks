# VSTS Tasks for Azure Automation
Visual Studio Team Services tasks for integrating with Azure Automation

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

## Using sample scripts/resources to test the extension: 

At the root of this repository, there is a folder called 'Samples' which contains a sample runbook, configuration, and some modules. The sample runbook comes with an optional parameter file that you can include in your runbook task if you'd like. The "simple" configuration comes with an optional parameter file. The "complex" configuration comes with its own optional parameter file and a mandatory configuration data file. The complex configuration sample also requires some DSC resources in order to be compiled and therefore calls the 'Import-DscResource' commandlet. This allows you to test implicitly uploading required DSC resources (modules) to your Automation Account given that you choose to provide a Storage Account in the DSC task when importing a new configuration. 

## To add more tasks to the extension: 

1. At the root of the directory in which you have cloned this repository, create a new folder for your task
1. Inside this new folder, add: a JSON file named 'task.json', the powershell script which contains your code for the task, and the 32x32 pixel png of the Azure Automation logo named 'icon.png'
1. Look at how other task.json files are written in this repository to understand how to write one for your task 
1. You will need to generate a new GUID to use for the "id" field in the task.json file
1. In the manifest file of this extension (vss-extension.json), add your task to the "contributions" field
1. Also add the folder you created for your task under the "files" field in the extension manifest file
