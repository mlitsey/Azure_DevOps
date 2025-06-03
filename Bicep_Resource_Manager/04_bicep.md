# Create composable Bicep files by using modules
[Link](https://learn.microsoft.com/en-us/training/modules/create-composable-bicep-files-using-modules/1-introduction)  


# Introduction

Bicep modules let you split a complex template into smaller parts. You can ensure that each module is focused on a specific task, and that the modules are reusable for multiple deployments and workloads.

In this module, you'll learn about the benefits of Bicep modules and how you can create, use, and combine them for your own deployments.

## Example scenario

Suppose you're responsible for deploying and configuring the Azure infrastructure at a toy company. You've previously created a Bicep template that deploys websites to support the launch of each new toy product.

Your company recently launched a new toy: a remote control wombat. The wombat toy has become popular, and the traffic to its website has increased significantly. Customers are complaining about slow response times because the server can't keep up with the demand.

To improve performance and reduce cost, you've been asked to add a content delivery network, or CDN, to the website. You know that your company will need to include a CDN in other websites that it makes in the future, but also that not every website needs a CDN. So you decide to make the CDN component optional.

![Architecture diagram that shows two variants: one with traffic flowing from the internet to the app through a CDN, and another without a CDN.](https://learn.microsoft.com/en-us/training/modules/create-composable-bicep-files-using-modules/media/1-architecture-diagram.png)

## What will we be doing?

In this module, you'll create a set of Bicep modules to deploy your website and CDN. Then, you'll create a template that uses those modules together.

## What is the main goal?

By the end of this module, you'll be able to design and build Bicep modules that are composable, reusable, and flexible. You'll also be able to create Bicep templates that compose complex deployments from a set of modules.


# Create and use Bicep modules

Completed 100 XP

-   10 minutes

Modules are independent Bicep files. They typically contain sets of resources that are deployed together. Modules can be consumed from any other Bicep template.

By using modules, you can reuse your Bicep code, and you can make your Bicep files more readable and understandable because they're each focused on a specific job. Your main templates then compose multiple modules together.

## The benefits of modules

In your toy company, you've been provisioning cloud resources by using many individual Bicep files. Over time, these templates grow significantly. Eventually, you end up having monolithic code that's difficult to read and navigate, and even harder to maintain.

This approach also forces you to duplicate parts of your code when you want to reuse it in other templates. When you change something, you need to search through and update multiple files.

Bicep modules help you address these challenges by splitting your code into smaller, more manageable files that multiple templates can reference. Modules give you some key benefits.

### Reusability

After you've created a module, you can reuse it in multiple Bicep files, even if the files are for different projects or workloads. For example, when you build out one solution, you might create separate modules for the app components, the database, and the network-related resources. Then, when you start to work on another project with similar network requirements, you can reuse the relevant module.

![Diagram that shows a template referencing three modules: application, database, and networking. The networking module is then reused in another template.](https://learn.microsoft.com/en-us/training/modules/includes/media/bicep-templates-modules.png)

You can even share modules within your team, within your organization, or with the Azure community. You'll learn more about sharing Bicep modules in a future Microsoft Learn module.

### Encapsulation

Modules help you keep related resource definitions together. For example, when you define an Azure Functions app, you typically deploy the app, a hosting plan for the app, and a storage account for the app's metadata. These three components are defined separately, but they represent a logical grouping of resources, so it might make sense to define them as a module.

That way, your main template doesn't need to be aware of the details of how a function app is deployed. That's the responsibility of the module.

### Composability

After you've created a set of modules, you can compose them together. For example, you might create a module that deploys a virtual network, and another module that deploys a virtual machine. You define parameters and outputs for each module so that you can take the important information from one and send it to the other.

![Diagram that shows a template referencing two modules and passing the output from one to the parameter of another.](https://learn.microsoft.com/en-us/training/modules/create-composable-bicep-files-using-modules/media/2-compose.png)

> 💡 **Tip**  
>It's helpful to think of Bicep modules as building blocks that you can combine in different ways to support your deployments.

### Functionality

Occasionally, you might need to use modules to access certain functionality. For example, you can use modules and loops together to deploy multiple sets of resources. You can also use modules to define resources at different scopes in a single deployment.

## Create a module

A module is a normal Bicep file. You'll create it just like you do any other Bicep file.

Generally, it's not a good practice to create a module for every resource that you deploy. A good Bicep module typically defines multiple related resources. However, if you have a complex resource with a lot of configuration, it might make sense to create a single module to encapsulate the complexity. This approach keeps your main templates simple and uncluttered.

### Split an existing Bicep template into modules

You might build up a large Bicep template and then decide that it should be split up into modules. Sometimes, it's obvious how you should split a large Bicep file. You might have a set of resources that clearly belong together in a module. Other times, it's not as straightforward to determine the resources that should be grouped into a module.

The Bicep visualizer can help you put your whole Bicep file in perspective. The visualizer is included in the Bicep extension for Visual Studio Code.

To view the visualizer, open Visual Studio Code Explorer, select and hold (or right-click) the Bicep file, then select **Open Bicep Visualizer**. The visualizer shows a graphical representation of the resources in your Bicep file. It includes lines between resources to show the dependencies that Bicep detects.

You can use the visualizer to help you to split up your files. Consider whether the visualization illustrates any clusters of resources. It might make sense to move these clusters into a module together.

For example, consider the following visualization for a Bicep file. Two distinct sets of resources are defined. It might make sense to group them into separate _database_ and _networking_ modules.

-   [Visualizer](https://learn.microsoft.com/en-us/training/modules/create-composable-bicep-files-using-modules/2-create-use-bicep-modules?tabs=visualizer#tabpanel_1_visualizer)
-   [Grouping](https://learn.microsoft.com/en-us/training/modules/create-composable-bicep-files-using-modules/2-create-use-bicep-modules?tabs=visualizer#tabpanel_1_grouping)

![Screenshot of the Bicep visualizer.](https://learn.microsoft.com/en-us/training/modules/create-composable-bicep-files-using-modules/media/2-visualizer.png)

![Screenshot of the Bicep visualizer with the resources grouped into a database module and a networking module.](https://learn.microsoft.com/en-us/training/modules/create-composable-bicep-files-using-modules/media/2-visualizer-annotated.png)

### Nest modules

Modules can include other modules. By using this nesting technique, you can create some modules that deploy small sets of resources, then compose these into larger modules that define complex topologies of resources. A template combines these pieces into a deployable artifact.

> 💡 **Tip**  
>Although it's possible to nest multiple layers of modules, that can become complex. If you get an error or something else goes wrong, it's harder to work out what you need to fix when you have many layers of nesting.
>
>For complex deployments, sometimes it makes sense to use deployment pipelines to deploy multiple templates instead of creating a single template that does everything with nesting. You'll learn more about deployment pipelines in a future Microsoft Learn module.

### Choose good file names

Be sure to use a descriptive file name for each module. The file name effectively becomes the identifier for the module. It's important that your colleagues can understand the module's purpose just by looking at the file name.

## Use the module in a Bicep template

You'll use a module in a Bicep template by using the `module` keyword, like this:
```bicep
module appModule 'modules/app.bicep' = {
  name: 'myApp'
  params: {
    location: location
    appServiceAppName: appServiceAppName
    environmentType: environmentType
  }
}
```

A module definition includes the following components:

-   The `module` keyword.
-   A symbolic name, like `appModule`. This name is used within this Bicep file whenever you want to refer to the module. The symbolic name never appears in Azure.
-   The module path, like `modules/app.bicep`. This is typically the path to a Bicep file on your local file system. In a future Microsoft Learn module, you'll learn about how you can share modules by using registries and template specs, which have their own module path formats.
    
    > 💡 **Tip**  
    >
    >You can also use a JSON Azure Resource Manager template (ARM template) as a module. This ability can be helpful if you have a set of templates that you haven't yet migrated to Bicep.
    
-   The `name` property, which specifies the name of the deployment. You'll learn more about deployments in the next section.
-   The `params` property, where you can specify values for the parameters that the module expects. You'll learn more about module parameters in the next unit.

## How modules work

Understanding how modules work isn't necessary for using them, but it can help you investigate problems with your deployments or help explain unexpected behavior.

### Deployments

In Azure, a _deployment_ is a special resource that represents a deployment operation. Deployments are Azure resources that have the resource type `Microsoft.Resources/deployments`. When you submit a Bicep deployment, you create or update a deployment resource. Similarly, when you create resources in the Azure portal, the portal creates a deployment resource on your behalf.

However, not all changes to Azure resources create or use deployments. For example, when you use the Azure portal to modify an existing resource, it generally doesn't create a deployment to make the change. When you use third-party tools like Terraform to deploy or configure your resources, they might not create deployments.

When you deploy a Bicep file by using the Azure CLI or Azure PowerShell, you can optionally specify the name of the deployment. If you don't specify a name, the Azure CLI or Azure PowerShell automatically creates a deployment name for you from the file name of the template. For example, if you deploy a file named _main.bicep_, the default deployment name is `main`.

When you use modules, Bicep creates a separate deployment for every module. The `name` property that you specify for the module becomes the name of the deployment. When you deploy a Bicep file that contains a module, multiple deployment resources are created: one for the parent template and one for each module.

For example, suppose you create a Bicep file named _main.bicep_. It defines a module named `myApp`. When you deploy the _main.bicep_ file, two deployments are created. The first one is named `main`, and it creates another deployment named `myApp` that contains your application resources.

![Diagram that shows two Bicep files, each of which has a separate deployment name.](https://learn.microsoft.com/en-us/training/modules/create-composable-bicep-files-using-modules/media/2-deployments.png)

You can list and view the details of deployment resources to monitor the status of your Bicep deployments or to view history of deployments. However, when you reuse the same name for a deployment, Azure overwrites the last deployment with the same name. If you need to maintain the deployment history, ensure that you use a unique name for every deployment. You might include the date and time of the deployment in the name to help make it unique.

### Generated JSON ARM templates

When you deploy a Bicep file, Bicep converts it to a JSON ARM template. This conversion is also called _transpilation_. The modules that the template uses are embedded into the JSON file. Regardless of how many modules you include in your template, only a single JSON file will be created.

In the example discussed in the previous section, Bicep generates a single JSON file even though there were originally two Bicep files.

![Diagram that shows two Bicep files, which are transpiled into a single JSON file.](https://learn.microsoft.com/en-us/training/modules/create-composable-bicep-files-using-modules/media/2-transpile.png)




# Add parameters and outputs to modules

Each module that you create should have a clear purpose. Think of a module as having a _contract_. It accepts a set of parameters, creates a set of resources, and might provide some outputs back to the parent template. Whoever uses the module shouldn't need to worry about how it works, just that it does what they expect.

When you plan a module, consider:

-   What you need to know to be able to fulfill the module's purpose.
-   What anyone who consumes your module will expect to provide.
-   What anyone who consumes your module will expect to access as outputs.

## Module parameters

Think about the parameters that your module accepts, and whether each parameter should be optional or required.

When you create parameters for templates, it's a good practice to add default parameters where you can. In modules, it's not always as important to add default parameters, because your module will be used by a parent template that might use its own default parameters. If you have similar parameters in both files, both with default values, it can be hard for your template's users to figure out which default value will be applied and to enforce consistency. It's often better to leave the default value on the parent template and remove it from the module.

You should also think about how you manage parameters that control the SKUs for your resources and other important configuration settings. When you create a standalone Bicep template, it's common to embed business rules into your template. For example: _When I deploy a production environment, the storage account should use the GRS tier_. But modules sometimes present different concerns.

If you're building a module that needs to be reusable and flexible, remember that the business rules for each parent template might be different, so it might not make as much sense to embed business rules into generic modules. Consider defining the business rules in your parent template, then explicitly pass module configuration through parameters.

However, if you create a module that's intended to make it easy for your own organization to deploy resources that fit your specific needs, it makes sense to include business rules to simplify the parent templates.

Whatever parameters you include in your module, ensure that you add a meaningful description by using the `@description` attribute:
```bicep
@description('The name of the storage account to deploy.')
param storageAccountName string
```

## Use conditions

One of the goals with deploying an infrastructure by using code like Bicep is to avoid duplicating effort, or even creating several templates for the same or similar purposes. Bicep's features give you a powerful toolbox to create reusable modules that work for various situations. You can combine features like modules, expressions, default parameter values, and conditions to build reusable code that gives you the flexibility that you need.

Suppose you're creating a module that deploys an Azure Cosmos DB account. When it's deployed to your production environment, you need to configure the account to send its logs to a Log Analytics workspace. To configure logs to be sent to Log Analytics, you'll define a _diagnosticSettings_ resource.

You could achieve your requirement by adding a condition to the resource definition and making the workspace ID parameter optional by adding a default value:
```bicep
param logAnalyticsWorkspaceId string = ''

resource cosmosDBAccount 'Microsoft.DocumentDB/databaseAccounts@2022-08-15' = {
  // ...
}

resource cosmosDBAccountDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' =  if (logAnalyticsWorkspaceId != '') {
  scope: cosmosDBAccount
  name: 'route-logs-to-log-analytics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'DataPlaneRequests'
        enabled: true
      }
    ]
  }
}
```

When you include this module in a Bicep template, you can easily configure it to send the Azure Cosmos DB account logs to Log Analytics by setting a workspace ID. Or, if you don't need logs for the environment that you're deploying, omit the parameter. It has a default value. The module encapsulates the logic required to do the right thing for your requirements.

> 💡 **Tip**  
>
>Remember to test that your template is valid for both scenarios; when the `if` statement is evaluated as either `true` or `false`.

## Module outputs

Modules can define outputs. It's a good idea to create an output for the information that the parent template might need to use. For example, if your module defines a storage account, consider creating an output for the storage account's name so that the parent template can access it.

> ⚠️ **Warning**  
>
>Don't use outputs for secret values. Outputs are logged as part of the deployment history, so they're not appropriate for secure values. You can instead consider one of the following options:
>
>-   Use an output to provide the resource's name. Then the parent template can create an `existing` resource with that name and can look >up the secure value dynamically.
>-   Write the value to an Azure Key Vault secret. Have the parent template read the secret from the vault when it needs it.

A parent template can use module outputs in variables, can use properties for other resource definitions, or can expose variables and properties as outputs itself. By exposing and using outputs throughout your Bicep files, you can create reusable sets of Bicep modules that can be shared with your team and reused across multiple deployments. It's also a good practice to add a meaningful description to outputs by using the `@description` attribute:
```bicep
@description('The fully qualified Azure resource ID of the blob container within the storage account.')
output blobContainerResourceId string = storageAccount::blobService::container.id
```

> 💡 **Tip**
>
>You can also use dedicated services to store, manage, and access the settings that your Bicep template creates. Key Vault is designed to store secure values. [Azure App Configuration](https://learn.microsoft.com/en-us/azure/azure-app-configuration/overview) is designed to store other (non-secure) values.

## Chain modules together

It's common to create a parent Bicep file that composes multiple modules together. For example, imagine you're building a new Bicep template to deploy virtual machines that use dedicated virtual networks. You could create a module to define a virtual network. You could then take the virtual network's subnet resource ID as an output from that module and use it as an input to the virtual machine module:
```bicep
@description('Username for the virtual machine.')
param adminUsername string

@description('Password for the virtual machine.')
@minLength(12)
@secure()
param adminPassword string

module virtualNetwork 'modules/vnet.bicep' = {
  name: 'virtual-network'
}

module virtualMachine 'modules/vm.bicep' = {
  name: 'virtual-machine'
  params: {
    adminUsername: adminUsername
    adminPassword: adminPassword
    subnetResourceId: virtualNetwork.outputs.subnetResourceId
  }
}
```

In this example, symbolic names are used for the reference between the modules. This reference helps Bicep to automatically understand the relationships between the modules.

Because Bicep understands there's a dependency, it deploys the modules in sequence:

1.  Bicep deploys everything in the `virtualNetwork` module.
2.  If that deployment succeeds, Bicep accesses the `subnetResourceId` output value and passes it to the `virtualMachine` module as a parameter.
3.  Bicep deploys everything in the `virtualMachine` module.

> 📝 **Note**
>
>When you depend on a module, Bicep waits for the entire module deployment to finish. It's important to remember this when you plan your modules. If you create a module that defines a resource that takes a long time to deploy, any other resources that depend on that module will wait for the whole module's deployment to finish.




# Exercise - Create and use a module

You've been tasked with adding a content delivery network, or CDN, to your company's website for the launch of a toy wombat. However, other teams in your company have told you they don't need a CDN. In this exercise, you'll create modules for the website and the CDN, and you'll add the modules to a template.

During the process, you'll:

-   Add a module for your application.
-   Create a Bicep template that uses the module.
-   Add another module for the CDN.
-   Add the CDN module to your template, while making it optional.
-   Deploy the template to Azure.
-   Review the deployment history.

This exercise uses the [Bicep extension for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep). Be sure to install this extension in Visual Studio Code.

## Create a blank Bicep file

1.  Open Visual Studio Code.
    
2.  Create a new file called _main.bicep_.
    
3.  Save the empty file so that Visual Studio Code loads the Bicep tooling.
    
    You can either select **File** > **Save As** or select Ctrl+S on Windows (⌘+S on macOS). Be sure to remember where you save the file. For example, you might want to create a _templates_ folder to save it in.
    

## Create a module for your application

1.  Create a new folder called _modules_ in the same folder where you created your _main.bicep_ file. In the _modules_ folder, create a file called _app.bicep_. Save the file.
    
2.  Add the following content into the _app.bicep_ file:
```bicep
@description('The Azure region into which the resources should be deployed.')
param location string

@description('The name of the App Service app.')
param appServiceAppName string

@description('The name of the App Service plan.')
param appServicePlanName string

@description('The name of the App Service plan SKU.')
param appServicePlanSkuName string

resource appServicePlan 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSkuName
  }
}

resource appServiceApp 'Microsoft.Web/sites@2024-04-01' = {
  name: appServiceAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }
}

@description('The default host name of the App Service app.')
output appServiceAppHostName string = appServiceApp.properties.defaultHostName
```

This file deploys an Azure App Service plan and an app. Notice that the module is fairly generic. It doesn't include any assumptions about the names of resources, or the App Service plan's SKU. This makes it easy to reuse the module for different deployments.
    
3.  Save the changes to the file.
    

## Add the module to your Bicep template

Here, you add the _app_ module to your Bicep template as a starting point.

1.  Open the _main.bicep_ file.
    
2.  Add the following parameters and variable to the file:
```bicep
@description('The Azure region into which the resources should be deployed.')
param location string = 'westus3'

@description('The name of the App Service app.')
param appServiceAppName string = 'toy-${uniqueString(resourceGroup().id)}'

@description('The name of the App Service plan SKU.')
param appServicePlanSkuName string = 'F1'

var appServicePlanName = 'toy-product-launch-plan'
```

-   Because this is the template that you intend to deploy for your toy websites, it's a little more specific. The App Service plan name is defined as a variable. The SKU parameter has a default value that makes sense for the toy launch website.
    
    > 💡 **Tip**
    >
    >You're specifying that the `location` parameter should be set to `westus3`. Normally, you would create resources in the same location as the resource group by using the `resourceGroup().location` property. But when you work with the Microsoft Learn sandbox, you need to use certain Azure regions that don't match the resource group's location.
    
3.   Below the parameters, create a blank line. Now, type the first line of the app module definition:
```bicep
module app 'modules/app.bicep' = {
```

-   As you type, notice that the Bicep extension for Visual Studio Code helps you to scaffold the module declaration. When you type the path to your module and type the equals (`=`) character, a pop-up menu appears with several options.
    
4.   Select **Required properties** from the pop-up menu:
    
    ![Screenshot of Visual Studio Code that shows the option to scaffold a module with its required properties.](https://learn.microsoft.com/en-us/training/modules/create-composable-bicep-files-using-modules/media/4-module-scaffold.png)
    
5.   Complete the module declaration:
```bicep
module app 'modules/app.bicep' = {
  name: 'toy-launch-app'
  params: {
    appServiceAppName: appServiceAppName
    appServicePlanName: appServicePlanName
    appServicePlanSkuName: appServicePlanSkuName
    location: location
  }
}
```

6. At the bottom of the file, define an output:
```bicep
@description('The host name to use to access the website.')
output websiteHostName string = app.outputs.appServiceAppHostName
```

7. Save the chagnes to the file.

## Create a module for the content delivery network

1.  In the _modules_ folder, create a file called _cdn.bicep_. Save the file.
    
2.  Add the following content into the _cdn.bicep_ file:
```bicep
@description('The host name (address) of the origin server.')
param originHostName string

@description('The name of the CDN profile.')
param profileName string = 'cdn-${uniqueString(resourceGroup().id)}'

@description('The name of the CDN endpoint')
param endpointName string = 'endpoint-${uniqueString(resourceGroup().id)}'

@description('Indicates whether the CDN endpoint requires HTTPS connections.')
param httpsOnly bool

var originName = 'my-origin'

resource cdnProfile 'Microsoft.Cdn/profiles@2024-09-01' = {
  name: profileName
  location: 'global'
  sku: {
    name: 'Standard_Microsoft'
  }
}

resource endpoint 'Microsoft.Cdn/profiles/endpoints@2024-09-01' = {
  parent: cdnProfile
  name: endpointName
  location: 'global'
  properties: {
    originHostHeader: originHostName
    isHttpAllowed: !httpsOnly
    isHttpsAllowed: true
    queryStringCachingBehavior: 'IgnoreQueryString'
    contentTypesToCompress: [
      'text/plain'
      'text/html'
      'text/css'
      'application/x-javascript'
      'text/javascript'
    ]
    isCompressionEnabled: true
    origins: [
      {
        name: originName
        properties: {
          hostName: originHostName
        }
      }
    ]
  }
}

@description('The host name of the CDN endpoint.')
output endpointHostName string = endpoint.properties.hostName
```

This file deploys two resources: a CDN profile and a CDN endpoint.
    
3.  Save the changes to the file.
    

## Add the modules to the main Bicep template

1.  Open the _main.bicep_ file.
    
2.  Below the `appServicePlanSkuName` parameter, add the following parameter:
```bicep
@description('Indicates whether a CDN should be deployed.')
param deployCdn bool = true
```

3. Below the app module definition, define the cdn module:
```bicep
module cdn 'modules/cdn.bicep' = if (deployCdn) {
  name: 'toy-launch-cdn'
  params: {
    httpsOnly: true
    originHostName: app.outputs.appServiceAppHostName
  }
}
```

Notice that the module has a condition so that it's deployed only when the `deployCdn` parameter's value is set to `true`. Also, notice that the module's `originHostName` parameter is set to the value of the `appServiceAppHostName` output from the `app` module.
    
4.   Update the host name output so that it selects the correct host name. When a CDN is deployed, you want the host name to be that of the CDN endpoint.
```bicep
output websiteHostName string = deployCdn ? cdn.outputs.endpointHostName : app.outputs.appServiceAppHostName
```

5.  Save the changes to the file.
    

## Verify your Bicep file

After you've completed all of the preceding changes, your _main.bicep_ file should look like this example:
```bicep
@description('The Azure region into which the resources should be deployed.')
param location string = 'westus3'

@description('The name of the App Service app.')
param appServiceAppName string = 'toy-${uniqueString(resourceGroup().id)}'

@description('The name of the App Service plan SKU.')
param appServicePlanSkuName string = 'F1'

@description('Indicates whether a CDN should be deployed.')
param deployCdn bool = true

var appServicePlanName = 'toy-product-launch-plan'

module app 'modules/app.bicep' = {
  name: 'toy-launch-app'
  params: {
    appServiceAppName: appServiceAppName
    appServicePlanName: appServicePlanName
    appServicePlanSkuName: appServicePlanSkuName
    location: location
  }
}

module cdn 'modules/cdn.bicep' = if (deployCdn) {
  name: 'toy-launch-cdn'
  params: {
    httpsOnly: true
    originHostName: app.outputs.appServiceAppHostName
  }
}

@description('The host name to use to access the website.')
output websiteHostName string = deployCdn ? cdn.outputs.endpointHostName : app.outputs.appServiceAppHostName
```

If it doesn't, either copy the example or adjust your template to match the example.

## Deploy the Bicep template to Azure

To deploy this template to Azure, you need to sign in to your Azure account from the Visual Studio Code terminal. Be sure you've installed the [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli), and remember to sign in with the same account that you used to activate the sandbox.

1.  On the **Terminal** menu, select **New Terminal**. The terminal window usually opens in the lower half of your screen.
    
2.  If the terminal window displays **bash** on the right side, it means the correct shell is already open. Alternatively, if you see a bash shell icon on the right, you can select it to launch the shell.
    
    ![Screenshot of the Visual Studio Code terminal window, with the bash option shown.](https://learn.microsoft.com/en-us/training/modules/includes/media/bash.png)
    
    If a shell other than **bash** appears, select the shell dropdown arrow, and then select **Git Bash**.
    
    ![Screenshot of the Visual Studio Code terminal window, with the terminal shell dropdown shown and Git Bash Default selected.](https://learn.microsoft.com/en-us/training/modules/includes/media/select-shell-bash.png)
    
3.  In the terminal, go to the directory where you saved your template. For example, if you saved your template to the _templates_ folder, you can use this command:
    
    Azure CLI
    
        cd templates
        
    

### Install Bicep

Run the following command to ensure you have the latest version of Bicep:

Azure CLI

    az bicep install && az bicep upgrade
    

### Sign in to Azure

1.  In the Visual Studio Code terminal, sign in to Azure by running the following command:
    
    Azure CLI
    
        az login
        
    
2.  In the browser that opens, sign in to your Azure account. The Visual Studio Code terminal displays a list of the subscriptions associated with this account. Select the subscription called **Concierge Subscription**.
    
    If you've used more than one sandbox recently, the terminal might display more than one instance of _Concierge Subscription_. In this case, use the next two steps to set one as the default subscription.
    
    1.  Get the Concierge Subscription IDs.
        
        Azure CLI
        
              az account list \
               --refresh \
               --query "[?contains(name, 'Concierge Subscription')].id" \
               --output table
            
        
    2.  Set the default subscription by using the subscription ID. Replace _{your subscription ID}_ with the latest Concierge Subscription ID.
        
        Azure CLI
        
            az account set --subscription {your subscription ID}
            
        

### Set the default resource group

When you use the Azure CLI, you can set the default resource group and omit the parameter from the rest of the Azure CLI commands in this exercise. Set the default to the resource group that's created for you in the sandbox environment.

Azure CLI

    az configure --defaults group="[sandbox resource group name]"
    

### Deploy the template to Azure

Run the following code from the terminal in Visual Studio Code to deploy the Bicep template to Azure. This process can take a minute or two to finish, and then you'll get a successful deployment.

Azure CLI

    az deployment group create --name main --template-file main.bicep
    

The status `Running...` appears in the terminal.

To deploy this template to Azure, sign in to your Azure account from the Visual Studio Code terminal. Be sure you've [installed Azure PowerShell](https://learn.microsoft.com/en-us/powershell/azure/install-az-ps), and sign in to the same account that activated the sandbox.

1.  On the **Terminal** menu, select **New Terminal**. The terminal window usually opens in the lower half of your screen.
    
2.  If the terminal window displays **pwsh** or **powershell** on the right side, it means the correct shell is already open. Alternatively, if you see a PowerShell shell icon on the right, you can select it to launch the shell.
    
    ![Screenshot of the Visual Studio Code terminal window, with the pwsh option displayed in the shell dropdown list.](https://learn.microsoft.com/en-us/training/modules/includes/media/pwsh.png)
    
    If a shell other than **pwsh** or **powershell** appears, select the shell dropdown arrow, and then select **PowerShell**.
    
    ![Screenshot of the Visual Studio Code terminal window, with the terminal shell dropdown list shown and PowerShell selected.](https://learn.microsoft.com/en-us/training/modules/includes/media/select-shell-powershell.png)
    
3.  In the terminal, go to the directory where you saved your template. For example, if you saved your template in the _templates_ folder, you can use this command:
    
    Azure PowerShell
    
        Set-Location -Path templates
        
    

### Install the Bicep CLI

To use Bicep from Azure PowerShell, [install the Bicep CLI](https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/bicep-install?tabs=azure-powershell#azure-powershell).

### Sign in to Azure by using Azure PowerShell

1.  In the Visual Studio Code terminal, run the following command:
    
    Azure PowerShell
    
        Connect-AzAccount
        
    
    A browser opens so that you can sign in to your Azure account. The browser might be opened in the background.
    
2.  After you've signed in to Azure, the terminal displays a list of the subscriptions associated with this account. If you've activated the sandbox, a subscription named _Concierge Subscription_ is displayed. Select it for the rest of the exercise.
    
    If you've used more than one sandbox recently, the terminal might display more than one instance of _Concierge Subscription_. In this case, use the next two steps to set one as the default subscription.
    
    1.  Get the subscription ID. Running the following command lists your subscriptions and their IDs. Look for `Concierge Subscription`, and then copy the ID from the second column. It looks something like `aaaa0a0a-bb1b-cc2c-dd3d-eeeeee4e4e4e`.
        
        Azure PowerShell
        
            Get-AzSubscription
            
        
    2.  Change your active subscription to _Concierge Subscription_. Be sure to replace _{Your subscription ID}_ with the one that you copied.
        
        Azure PowerShell
        
            $context = Get-AzSubscription -SubscriptionId {Your subscription ID}
            Set-AzContext $context
            
        

### Set the default resource group

You can set the default resource group and omit the parameter from the rest of the Azure PowerShell commands in this exercise. Set this default to the resource group created for you in the sandbox environment.

Azure PowerShell

    Set-AzDefault -ResourceGroupName [sandbox resource group name]
    

### Deploy the template to Azure

Deploy the template to Azure by using the following Azure PowerShell command in the terminal. This can take a minute or two to finish, and then you'll get a successful deployment.

Azure PowerShell

    New-AzResourceGroupDeployment -Name main -TemplateFile main.bicep
    

## Review the deployment history

1.  Go to the [Azure portal](https://portal.azure.com/) and make sure you're in the sandbox subscription:
    
    1.  Select your avatar in the upper-right corner of the page.
    2.  Select **Switch directory**. In the list, choose the **Microsoft Learn Sandbox** directory.
2.  On the left-side panel, select **Resource groups**.
    
3.  Select **\[sandbox resource group name\]**.
    
4.  On the left menu, select **Deployments**.
    
    ![Screenshot of the Azure portal that shows the resource group, with the Deployments menu item highlighted.](https://learn.microsoft.com/en-us/training/modules/create-composable-bicep-files-using-modules/media/4-deployments.png)
    
    Three deployments are listed.
    
5.  Select the **main** deployment and expand **Deployment details**.
    
    Notice that both of the modules are listed, and that their types are displayed as `Microsoft.Resources/deployments`. The modules are listed twice because their outputs are also referenced within the template.
    
    ![Screenshot of the Azure portal that shows the deployment details for the main deployment.](https://learn.microsoft.com/en-us/training/modules/create-composable-bicep-files-using-modules/media/4-deployment-modules.png)
    
6.  Select the **toy-launch-cdn** and **toy-launch-app** deployments and review the resources deployed in each. Notice that they correspond to the resources defined in the respective module.
    

## Test the website

1.  Select the **toy-launch-app** deployment.
    
2.  Select **Outputs**.
    
    ![Screenshot of the Azure portal that shows the deployment, with the Outputs menu item highlighted.](https://learn.microsoft.com/en-us/training/modules/create-composable-bicep-files-using-modules/media/4-outputs.png)
    
3.  Select the copy button for the `appServiceAppHostName` output.
    
4.  On a new browser tab, try to go to the address that you copied in the previous step. The address should begin with `https://`.
    
    ![Screenshot of the web app's welcome page, with the address bar showing the App Service host name.](https://learn.microsoft.com/en-us/training/modules/create-composable-bicep-files-using-modules/media/4-web-app.png)
    
    The App Service welcome page appears, showing that you've successfully deployed the app.
    
5.  Go to the **main** deployment and select **Outputs**.
    
6.  Copy the value of the `websiteHostName` output. Notice that this host name is different, because it's an Azure Content Delivery Network host name.
    
7.  On a new browser tab, try to go to the host name that you copied in the previous step. Add `https://` to the start of the address.
    
    CDN endpoints take a few minutes to become active. If you get a _Page not found_ error, wait a few minutes and try pasting the link again. Also, ensure that you added `https://` to the start of the URL so that you're using HTTPS.
    
    When the CDN endpoint is active, you'll get the same App Service welcome page. This time, it has been served through the Azure Content Delivery Network service, which helps improve the website's performance.
    
    ![Screenshot of the web app's welcome page, with the address bar showing the CDN endpoint.](https://learn.microsoft.com/en-us/training/modules/create-composable-bicep-files-using-modules/media/4-web-cdn.png)




# Module Assessment