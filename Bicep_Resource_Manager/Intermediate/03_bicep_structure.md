# Structure your Bicep code for collaboration
[Link](https://learn.microsoft.com/en-us/training/modules/structure-bicep-code-collaboration/1-introduction)  


# Introduction

One of the benefits of deploying your infrastructure as code is that your templates are shareable, allowing you to collaborate on your Bicep code with other team members. It's important to make your Bicep code easy to read and easy to work with.

In this module, you'll learn some ways to structure and style your Bicep code so that it's easy for others to understand, modify, and deploy.

## Example scenario

Suppose you're an Azure infrastructure administrator at a toy company. You and your team have standardized on using Bicep for your Azure deployments, and you've built a library of reusable templates.

Two members of the quality control team have been tasked to run a customer survey. To accomplish this, they need to deploy a new website and database. They're on a tight deadline, and they want to avoid building a whole new template if they don't have to. After you've spoken with them about their requirements, you remember that you already have a template that's close to what they need.

The template is one of the first Bicep files you wrote, so you're worried that it might not be ready for them to use. The question is, how can you revise the template to ensure that it's correct, easy to understand, easy to read, and easy to modify?

## What will we be doing?

In this module, you'll learn how to improve and refactor Bicep files to make your code easier for others to work with. You'll learn how parameters and names are an important part of making your Bicep code and Azure deployments useful to others. You'll also learn how to define your template structure, follow a consistent style, and add comments that help your colleagues understand how your template works.

## What is the main goal?

By the end of this module, you'll be able to author Bicep templates that are clear, reusable, and well documented.

## Prerequisites

You should be familiar with Bicep structure and syntax, including parameters, loops, conditions, and modules.

To follow along with the exercises in the module, you'll need the following:

-   [Visual Studio Code](https://code.visualstudio.com/) installed locally
-   The [Bicep extension for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep) installed locally


# Exercise - Review your existing Bicep template

In our scenario, you sit down to review your template with your colleagues from the quality control team.

As you work together through the template, your colleagues begin asking a series of questions about the structure and components of the file. They seem to have some confusion. Maybe your template could benefit from some improvements to make it more readable and easier to understand?

Take a look at the following template, which you're seeing for the first time. Do you understand what everything in the template is doing? How many issues can you find? What could you do to improve the template?

Bicep Code
```bicep
    param location string = resourceGroup().location
    
    @allowed([
      'F1'
      'D1'
      'B1'
      'B2'
      'B3'
      'S1'
      'S2'
      'S3'
      'P1'
      'P2'
      'P3'
      'P4'
    ])
    param skuName string = 'F1'
    
    @minValue(1)
    param skuCapacity int = 1
    param sqlAdministratorLogin string
    
    @secure()
    param sqlAdministratorLoginPassword string
    
    param managedIdentityName string
    param roleDefinitionId string = 'b24988ac-6180-42a0-ab88-20f7382dd24c'
    param webSiteName string = 'webSite${uniqueString(resourceGroup().id)}'
    param container1Name string = 'productspecs'
    param productmanualsName string = 'productmanuals'
    
    var hostingPlanName = 'hostingplan${uniqueString(resourceGroup().id)}'
    var sqlserverName = 'toywebsite${uniqueString(resourceGroup().id)}'
    var storageAccountName = 'toywebsite${uniqueString(resourceGroup().id)}'
    
    resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
      name: storageAccountName
      location: 'eastus'
      sku: {
        name: 'Standard_LRS'
      }
      kind: 'StorageV2'
      properties: {
        accessTier: 'Hot'
      }
    
      resource blobServices 'blobServices' existing = {
        name: 'default'
      }
    }
    
    resource container1 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
      parent: storageAccount::blobServices
      name: container1Name
    }
    
    resource sqlserver 'Microsoft.Sql/servers@2023-08-01-preview' = {
      name: sqlserverName
      location: location
      properties: {
        administratorLogin: sqlAdministratorLogin
        administratorLoginPassword: sqlAdministratorLoginPassword
        version: '12.0'
      }
    }
    
    var databaseName = 'ToyCompanyWebsite'
    resource sqlserverName_databaseName 'Microsoft.Sql/servers/databases@2023-08-01-preview' = {
      name: '${sqlserver.name}/${databaseName}'
      location: location
      sku: {
        name: 'Basic'
      }
      properties: {
        collation: 'SQL_Latin1_General_CP1_CI_AS'
        maxSizeBytes: 1073741824
      }
    }
    
    resource sqlserverName_AllowAllAzureIPs 'Microsoft.Sql/servers/firewallRules@2023-08-01-preview' = {
      name: '${sqlserver.name}/AllowAllAzureIPs'
      properties: {
        endIpAddress: '0.0.0.0'
        startIpAddress: '0.0.0.0'
      }
      dependsOn: [
        sqlserver
      ]
    }
    
    resource productmanuals 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
      name: '${storageAccount.name}/default/${productmanualsName}'
    }
    resource hostingPlan 'Microsoft.Web/serverfarms@2023-12-01' = {
      name: hostingPlanName
      location: location
      sku: {
        name: skuName
        capacity: skuCapacity
      }
    }
    
    resource webSite 'Microsoft.Web/sites@2023-12-01' = {
      name: webSiteName
      location: location
      properties: {
        serverFarmId: hostingPlan.id
        siteConfig: {
          appSettings: [
            {
              name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
              value: AppInsights_webSiteName.properties.InstrumentationKey
            }
            {
              name: 'StorageAccountConnectionString'
              value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
            }
          ]
        }
      }
      identity: {
        type: 'UserAssigned'
        userAssignedIdentities: {
          '${msi.id}': {}
        }
      }
    }
    
    // We don't need this anymore. We use a managed identity to access the database instead.
    //resource webSiteConnectionStrings 'Microsoft.Web/sites/config@2020-06-01' = {
    //  name: '${webSite.name}/connectionstrings'
    //  properties: {
    //    DefaultConnection: {
    //      value: 'Data Source=tcp:${sqlserver.properties.fullyQualifiedDomainName},1433;Initial Catalog=${databaseName};User Id=${sqlAdministratorLogin}@${sqlserver.properties.fullyQualifiedDomainName};Password=${sqlAdministratorLoginPassword};'
    //      type: 'SQLAzure'
    //    }
    //  }
    //}
    
    resource msi 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
      name: managedIdentityName
      location: location
    }
    
    resource roleassignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
      name: guid(roleDefinitionId, resourceGroup().id)
    
      properties: {
        principalType: 'ServicePrincipal'
        roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
        principalId: msi.properties.principalId
      }
    }
    
    resource AppInsights_webSiteName 'Microsoft.Insights/components@2020-02-02' = {
      name: 'AppInsights'
      location: location
      kind: 'web'
      properties: {
        Application_Type: 'web'
      }
    }
```    

## Create and save the Bicep file

Throughout this module, you'll make changes that improve the template. You'll follow best practices to make it easier to read and understand, and easier for your colleagues to work with.

First, you need to create the Bicep file and save it locally so you can work with it.

1.  Open Visual Studio Code.
    
2.  Create a new file called _main.bicep_.
    
3.  Copy the preceding Bicep template and paste it into the file.
    
4.  Save the changes to the file.
    

> ⚠️ **Important**
>
>The process of improving code by reorganizing and renaming it is called _refactoring_. When you refactor code, it's a good idea to use a version-control system such as Git. With version control, you can make changes to your code, undo those changes, or return to a previous version.
>
>In this module, you're not required to use Git to track your file. It's a good idea to do so, however, so consider it an optional extra.


# Improve parameters and names

Parameters are the most common way that your colleagues will interact with your template. When they deploy your template, they need to specify values for the parameters. After it's created, a resource's name provides important information about its purpose to anyone who looks at your Azure environment.

In this unit, you'll learn about some key considerations when you're planning the parameters for Bicep files and the names you give your resources.

## How understandable are the parameters?

Parameters help make Bicep files reusable and flexible. It's important that the purpose of each parameter is clear to anyone who uses it. When your colleagues work with your template, they use parameters to customize the behavior of their deployment.

For example, suppose you need to deploy a storage account by using a Bicep file. One of the required properties of the storage account is the stock keeping unit (SKU), which defines the level of data redundancy. The SKU has several properties, the most important being `name`. When you create a parameter to set the value for the storage account's SKU, use a clearly defined name, such as `storageAccountSkuName`. Using this value instead of a generic name like `sku` or `skuName` will help others understand the purpose of the parameter and the effects of setting its value.

Default values are an important way to make your template usable by others. It's important to use default values where they make sense. They help your template's users in two ways:

-   Default values simplify the process of deploying your template. If your parameters have good default values that work for most of your template's users, the users can omit the parameter values instead of specifying them every time they deploy the template.
-   Default values provide an example of how you expect the parameter value to look. If template users need to choose a different value, the default value can provide useful hints about what their value should look like.

Bicep can also help to validate the input that users provide through _parameter decorators_. You can use these decorators to provide a parameter description or to state what kinds of values are permitted. Bicep provides several types of parameter decorators:

-   **Descriptions** provide human-readable information about the purpose of the parameter and the effects of setting its value.
    
-   **Value constraints** enforce limits on what users can enter for the parameter's value. You can specify a list of specific, permitted values by using the `@allowed()` decorator. You can use the `@minValue()` and `@maxValue()` decorators to enforce the minimum and maximum values for numeric parameters, and you can use the `@minLength()` and `@maxLength()` decorators to enforce the length of string and array parameters.
    
    > 💡 **Tip**
    >
    >Be careful when you use the `@allowed()` parameter decorator to specify SKUs. Azure services often add new SKUs, and you don't want your template to unnecessarily prohibit their use. Consider using Azure Policy to enforce the use of specific SKUs, and use the `@allowed()` decorator with SKUs only when there are functional reasons why your template's users shouldn't select a specific SKU. For example, the features that your template needs might not be available in that SKU. Explain this by using a `@description()` decorator or comment that makes the reasons clear to anyone in future.
    
-   **Metadata**, although not commonly used, can be applied to provide extra custom metadata about the parameter.
    

## How flexible should a Bicep file be?

One of the goals of defining your infrastructure as code is to make your templates reusable and flexible. You don't want to create single-purpose templates that have a hard-coded configuration. On the other hand, it doesn't make sense to expose all resource properties as parameters. Create templates that work for your specific business problem or solution, not generic templates that need to work for every situation. You also don't want to have so many parameters that it takes a long time to enter the values before you can deploy the template. This is particularly important when you configure the SKUs and instance counts of resources.

When you're planning a template, consider how you'll balance flexibility with simplicity. There are two common ways to provide parameters in templates:

-   Provide free-form configuration options
-   Use predefined configuration sets

Let's consider both approaches by using an example Bicep file that deploys a storage account and an Azure App Service plan.

### Provide free-form configuration options

Both the App Service plan and the storage account require that you specify their SKUs. You might consider creating a set of parameters to control each of the SKUs and instance counts for the resources:

![Diagram of the parameters controlling an app service plan and a storage account.](https://learn.microsoft.com/en-us/training/modules/structure-bicep-code-collaboration/media/3-free-form-configuration.png)

Here's how this looks in Bicep:

Bicep Code
```bicep
    param appServicePlanSkuName string
    param appServicePlanSkuCapacity int
    param storageAccountSkuName string
    
    resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
      name: appServicePlanName
      location: location
      sku: {
        name: appServicePlanSkuName
        capacity: appServicePlanSkuCapacity
      }
    }
    
    resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
      name: storageAccountSkuName
      location: location
      sku: {
        name: storageAccountSkuName
      }
    }
```    

This format provides the most flexibility, because anyone who uses the template can specify any combination of parameter values. However, as you add more resources, you need more parameters. As a result, your template becomes more complicated. Also, you might need to either restrict certain combinations of parameters or ensure that when a specific resource is deployed using one SKU, another resource needs to be deployed by using a different SKU. If you provide too many separate parameters, it's hard to enforce these rules.

> 💡 **Tip**
>
>Think about the people who will work with your template. Seeing dozens of parameters might overwhelm them and cause them to abandon using your template.
>
>You might be able to reduce the number of parameters by grouping related parameters in the form of a parameter object, like this:
>
>Bicep Code
> ```bicep
>    param appServicePlanSku object = {
>      name: 'S1'
>      capacity: 2
>    }
> ```    
>
>However, this approach can reduce your ability to validate the parameter values, and it's not always easy for your template users to understand how to define the object.

### Use predefined configuration sets

Alternatively, you could provide a _configuration set_: a single parameter, whose value is a restricted list of allowed values, such as a list of environment types. When users deploy your template, they need to select a value for only this one parameter. When they select a value for the parameter, the deployment automatically inherits a set of configuration:

![Diagram of a configuration set controlling an app service plan and a storage account.](https://learn.microsoft.com/en-us/training/modules/structure-bicep-code-collaboration/media/3-configuration-map.png)

The parameter definition looks like this:

Bicep Code
```bicep
    @allowed([
      'Production'
      'Test'
    ])
    param environmentType string = 'Test'
```    

Configuration sets offer lower flexibility, because people who deploy your template can't specify sizes for individual resources, but you can validate each set of configurations and ensure that they fit your requirements. Using configuration sets reduces the need for your template's users to understand all the different options available for each resource, and it becomes easier to support, test, and troubleshoot your templates.

When you work with configuration sets, you create a _map_ variable to define the specific properties to set on various resources, based on the parameter value:

Bicep Code
```bicep
    var environmentConfigurationMap = {
      Production: {
        appServicePlan: {
          sku: {
            name: 'P2V3'
            capacity: 3
          }
        }
        storageAccount: {
          sku: {
            name: 'ZRS'
          }
        }
      }
      Test: {
        appServicePlan: {
          sku: {
            name: 'S2'
            capacity: 1
          }
        }
        storageAccount: {
          sku: {
            name: 'LRS'
          }
        }
      }
    }
```    

Your resource definitions then use the configuration map to define the resource properties:

Bicep Code

    resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
      name: appServicePlanName
      location: location
      sku: environmentConfigurationMap[environmentType].appServicePlan.sku
    }
    

Configuration sets can help you make complex templates more easily accessible. They can also help you enforce your own rules and encourage the use of pre-validated configuration values.

> 📝 **Note**
>
>This approach is sometimes called _t-shirt sizing_. When you buy a t-shirt, you don't get a lot of options for length, width, sleeves, and so forth. You simply choose from small, medium, and large sizes, and the t-shirt designer has predefined those measurements based on that size.

## How are your resources named?

In Bicep, it's important to give your resources meaningful names. Resources in Bicep have two names:

-   **Symbolic names** are used only within the Bicep file and don't appear on your Azure resources. Symbolic names help users who read or modify your template to understand the purpose of a parameter, variable, or resource definition, and they help users make informed decisions about whether to change the template.
    
-   **Resource names** are the names of the resources that are created in Azure. Many resources have constraints on their names, and many require their names to be unique.
    

### Symbolic names

It's important to think about the symbolic names you apply to your resources. Imagine that you have colleagues who need to modify the template. Will they understand what each resource is for?

For example, suppose you want to define a storage account that will contain product manuals for users to download from your website. You could give the resource a symbolic name of (for example) `storageAccount`, but if it's in a Bicep file that contains a lot of other resources, and maybe even other storage accounts, that name isn't sufficiently descriptive. Instead, you could give it a symbolic name that includes some information about its purpose, such as `productManualStorageAccount`.

In Bicep, you ordinarily use _camelCase_ capitalization style for the names of parameters, variables, and resource symbolic names. This means that you use a lowercase first letter for the first word, and then capitalize the first letter of the other words (as in the preceding example, `productManualStorageAccount`). You're not required to use camelCase. If you choose to use a different style, it's important to agree on one standard within your team and use it consistently.

### Resource names

Every Azure resource has a name. Names make up a part of the resource's identifier. In many cases, they're also represented as the hostnames that you use to access the resource. For example, when you create an App Service app named `myapp`, the hostname you use to access the app will be `myapp.azurewebsites.net`. You can't rename resources after they're deployed.

It's important to consider how you name your Azure resources. Many organizations define their own resource-naming convention. [Cloud Adoption Framework for Azure has specific guidance](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging) that can help you define yours. The purpose of a resource naming convention is to help everyone in your organization understand what each resource is for.

Additionally, every Azure resource has certain naming [rules and restrictions](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules). For example, there are restrictions around the length of names, the characters they can include, and whether names have to be globally unique or just unique within a resource group.

It can be complex to follow all of the naming conventions for your organization as well as the naming requirements for Azure. A well-written Bicep template should hide this complexity from its users and determine the names for resources automatically. Here's one example of an approach to follow:

-   Add a parameter that's used to create a _uniqueness suffix_. This helps to ensure that your resources have unique names. It's a good idea to use the `uniqueString()` function to generate a default value. People who deploy your template can override this with a specific value if they want to have a meaningful name. Be sure to use the `@maxLength()` decorator to limit the length of this suffix so that your resource names won't exceed their maximum lengths.
    
    > 💡 **Tip**
    >
    >It's better to use uniqueness suffixes rather than prefixes. This approach makes it easier to sort and to quickly scan your resource names. Also, some Azure resources have restrictions about the first character of the name, and randomly generated names can sometimes violate these restrictions.
    
-   Use variables to construct resource names dynamically. Your Bicep code can ensure that the names it generates follow your organization's naming convention as well as Azure requirements. Include the uniqueness suffix as part of the resource name.
    
    > 📝 **Note**
    >
    >Not every resource requires a globally unique name. Consider whether you include the uniqueness suffix in the names of every resource or just those that need it.


# Plan the structure of your Bicep file

Bicep gives you the flexibility to decide how to structure your code. In this unit, you'll learn about the ways you can structure your Bicep code, and the importance of a consistent style and clear, understandable Bicep code.

## What order should your Bicep code follow?

Your Bicep templates can contain many elements, including parameters, variables, resources, modules, outputs, and a `targetScope` for the entire template. Bicep doesn't enforce an order for your elements to follow. However, it's important to consider the order of your elements to ensure that your template is clear and understandable.

There are two main approaches to ordering your code:

-   Group elements by element type
-   Group elements by resource

You and your team should agree on one and use it consistently.

### Group elements by element type

You can group all elements of the same type together. All your parameters would go in one place, usually at the top of the file. Variables come next, followed by resources and modules, and outputs are at the bottom. For example, you might have a Bicep file that deploys an Azure SQL database and a storage account.

When you group your elements by type, they might look like this:

![Diagram showing elements grouped by element type. Parameters are grouped together, then variables, then resources, then outputs.](https://learn.microsoft.com/en-us/training/modules/structure-bicep-code-collaboration/media/4-group-element-type.png)

Tip

If you follow this convention, consider putting the `targetScope` at the top of the file.

This ordering makes sense when you're used to other infrastructure as code languages (for example, the language in Azure Resource Manager templates). It can also make your template easy to understand, because it's clear where to look for specific types of elements. In longer templates, though, it can be challenging to navigate and jump between the elements.

You still have to decide how to order the elements within these categories. It's a good idea to group related parameters together. For example, all parameters that are about a storage account belong together and, within that, the storage account's SKU parameters belong together.

Similarly, you can group related resources together. Doing so helps anyone who uses your template to quickly navigate it and to understand the important parts of the template.

Sometimes, you create a template that deploys a primary resource with multiple secondary supporting resources. For example, you might create a template to deploy a website that's hosted on Azure App Service. The primary resource is the App Service app. Secondary resources in the same template might include the App Service plan, storage account, Application Insights instance, and others. When you have a template like this, it's a good idea to put the primary resource or resources at the top of the resource section of the template, so that anyone who opens the template can quickly identify the template's purpose and can find the important resources.

### Group elements by resource

Alternatively, you can group your elements based on the type of resources you're deploying. Continuing the preceding example, you could group all the parameters, variables, resources, and outputs that relate to the Azure SQL database resources. You could then add the parameters, variables, resources, and outputs for the storage account, as shown here:

![Diagram showing elements grouped by resource. Storage account elements are grouped, followed by Azure SQL database elements.](https://learn.microsoft.com/en-us/training/modules/structure-bicep-code-collaboration/media/4-group-resource.png)

Grouping by resource can make it easier to read your template, because all the elements you need for a specific resource are in one place. However, it makes it harder to quickly check how specific element types are declared when, for example, you want to review all your parameters.

You also need to consider how to handle parameters and variables that are common to multiple resources, such as an `environmentType` parameter when you use a configuration map. Common parameters and variables should be placed together, usually at the top of the Bicep file.

Tip

Consider whether it might make more sense to create _modules_ for groups of related resources, and then use a simpler template to combine the modules. We cover Bicep modules in more detail throughout the Bicep learning paths.

## How can white space help create structure?

Blank lines, or _white space_, can help you add visual structure to your template. By using white space thoughtfully, you can group the sections of your Bicep code logically, which can in turn help clarify the relationships between resources. To do this, consider adding a blank line between major sections, regardless of the grouping style you prefer.

## How do you define several similar resources?

With Bicep, you can use loops to deploy similar resources from a single definition. By using the `for` keyword to define resource loops, you can make your Bicep code cleaner and reduce unnecessary duplication of resource definitions. In the future, when you need to change the definition of your resources, you just update one place. By default, when Azure Resource Manager deploys your resources, it deploys all the resources in the loop at the same time, so your deployment is as efficient as possible.

Look for places where you define multiple resources that are identical, or that have few differences in their properties. Then, add a variable to list the resources to create, along with the properties that differ from the other resources. The following example uses a loop to define a set of Azure Cosmos DB containers, each of which has its own name and partition key:

Bicep Code

    var cosmosDBContainerDefinitions = [
      {
        name: 'customers'
        partitionKey: '/customerId'
      }
      {
        name: 'orders'
        partitionKey: '/orderId'
      }
      {
        name: 'products'
        partitionKey: '/productId'
      }
    ]
    
    resource cosmosDBContainers 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-05-15' = [for cosmosDBContainerDefinition in cosmosDBContainerDefinitions: {
      parent: cosmosDBDatabase
      name: cosmosDBContainerDefinition.name
      properties: {
        resource: {
          id: cosmosDBContainerDefinition.name
          partitionKey: {
            kind: 'Hash'
            paths: [
              cosmosDBContainerDefinition.partitionKey
            ]
          }
        }
        options: {}
      }
    }]
    

## How do you deploy resources only to certain environments?

Sometimes, you define resources that should be deployed only to specific environments or under certain conditions. By using the `if` keyword, you can selectively deploy resources based on a parameter value, a configuration map variable, or another condition. The following example uses a configuration map to deploy logging resources for production environments, but not for test environments:

Bicep Code

    var environmentConfigurationMap = {
      Production: {
        enableLogging: true
      }
      Test: {
        enableLogging: false
      }
    }
    
    resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = if (environmentConfigurationMap[environmentType].enableLogging) {
      name: logAnalyticsWorkspaceName
      location: location
    }
    
    resource cosmosDBAccountDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (environmentConfigurationMap[environmentType].enableLogging) {
      scope: cosmosDBAccount
      name: cosmosDBAccountDiagnosticSettingsName
      properties: {
        workspaceId: logAnalyticsWorkspace.id
        // ...
      }
    }
    

## How do you express dependencies between your resources?

In any complex Bicep template, you need to express _dependencies_ between your resources. When Bicep understands the dependencies between your resources, it deploys them in the correct order.

Bicep allows you to explicitly specify a dependency by using the `dependsOn` property. However, in most cases, it's possible to let Bicep automatically detect dependencies. When you use the symbolic name of one resource within a property of another, Bicep detects the relationship. It's better to let Bicep manage these itself whenever you can. That way, when you change your template, Bicep will make sure the dependencies are always correct, and you won't add unnecessary code that makes your template more cumbersome and harder to read.

## How do you express parent-child relationships?

Azure Resource Manager and Bicep have the concept of _child resources_, which makes sense only when they're deployed within the context of their parent. For example, an Azure SQL database is a child of a SQL server instance. There are several ways to define child resources, but in most cases, it's a good idea to use the `parent` property. This helps Bicep to understand the relationship so it can provide validation in Visual Studio Code, and it makes the relationship clear to anyone else who reads the template.

## How do you set resource properties?

You need to specify the values for resource properties in your Bicep files. It's a good idea to be thoughtful when you're hard-coding values into your resource definitions. If you know the values won't change, hard-coding them might be better than using another parameter that makes your template harder to test and work with. If the values might change, though, consider defining them as parameters or variables to make your Bicep code more dynamic and reusable.

When you do hard-code values, it's good to make sure that they're understandable to others. For example, if a property has to be set to a specific value for the resource to behave correctly for your solution, consider creating a well-named variable that provides an explanation, then assigning the value by using the variable. For situations where a variable name doesn't tell the whole story, consider adding a comment. You'll learn more about comments later in this module.

For some resource properties, to construct values automatically, you need to create complex expressions that include functions and string interpolation. Your Bicep code is usually clearer when you declare variables and reference them in the resource code blocks.

Tip

When creating outputs, try to use resource properties wherever you can. Avoid incorporating your own assumptions about how resources work, because these assumptions might change over time.

For example, if you need to output the URL of an App Service app, avoid constructing a URL:

Bicep Code

    output hostname string = '${app.name}.azurewebsites.net'
    

The preceding approach will break if App Service changes the way they assign hostnames to apps, or if you deploy to Azure environments that use different URLs.

Instead, use the `defaultHostname` property of the app resource:

Bicep Code

    output hostname string = app.properties.defaultHostname
    

## How do you use version control effectively?

Version-control systems such as Git can help simplify your work when you're refactoring code.

Because version-control systems are designed to keep track of the changes to your files, you can use them to easily return to an older version of your code if you make a mistake. It's a good idea to commit your work often so that you can go back to the exact point in time that you need.

Version control also helps you to remove old code from your Bicep files. What if your Bicep code includes a resource definition that you don't need anymore? You might need the definition again in the future, and it's tempting to simply comment it out and keep it in the file. But really, keeping it there only clutters up your Bicep file, making it hard for others to understand why the commented-out resources are still there.

Another consideration is that it's possible for someone to accidentally uncomment the definition, with unpredictable or potentially adverse results. When you use a version-control system, you can simply remove the old resource definition. If you need the definition again in the future, you can retrieve it from the file history.


# Document your code by adding comments and metadata

Good Bicep code is _self-documenting_. This means that it uses clear naming and a good structure so that when colleagues read your code, they can quickly understand what's happening. If they need to make changes, they can be confident they're modifying the right places.

In some situations, though, you might need to clarify certain code by adding extra documentation to your Bicep files. Also, after your template is deployed and resources have been created in Azure, it's important that anyone who looks at your Azure environment understands what each resource is and what it's for.

In this unit, you'll learn how to add comments to your Bicep files and how to use resource tags to add metadata to your Azure resources. This additional documentation gives your colleagues insights into what your code does, the logic you used to write the code, and the purpose of your Azure resources.

## Add comments to your code

Bicep allows you to add _comments_ to your code. Comments are human-readable text that documents your code but is ignored when the file is deployed to Azure.

Bicep supports two types of comments:

-   **Single-line comments** start with a double slash (`//`) character sequence, and continue to the end of the line, as shown here:
    
    Bicep Code
    
        // We need to define a firewall rule to allow Azure services to access the database.
        
        resource firewallRule 'Microsoft.Sql/servers/firewallRules@2023-08-01-preview' = {
          parent: sqlServer
          name: 'AllowAllAzureIPs'
          properties: {
            startIpAddress: '0.0.0.0' // This combination represents 'all Azure IP addresses'.
            endIpAddress: '0.0.0.0'
          }
        }
        
    
-   **Multi-line comments** use the `/*` and `*/` character sequences to surround the comment, and can span multiple lines, as shown here:
    
    Bicep Code
    
        /*
          This Bicep file was developed by the web team.
          It deploys the resources we need for our toy company's website.
        */
        
    

Tip

Avoid using comments for obvious and clear parts of your code. Having too many comments actually reduces your code's readability. Also, it's easy to forget to update comments when your code changes in the future. Focus on documenting unique logic and complex expressions.

You can also use Bicep comments to add a structured multi-line block at the beginning of each file. Think of it as a _manifest_. Your team might decide that each template and module should have a manifest that describes the purpose of the template and what it contains, such as in this example:

Bicep Code

    /*
      SYNOPSIS: Module for provisioning Azure SQL server and database.
      DESCRIPTION: This module provisions an Azure SQL server and a database, and configures the server to accept connections from within Azure.
      VERSION: 1.0.0
      OWNER TEAM: Website
    */
    

### Add comments to parameter files

Parameter files allow you to create a JSON file to specify a set of parameter values for your deployment. The parameter values need to match the parameters that are declared in the Bicep template.

The values that you specify in parameter files also often benefit from being documented. It's a good practice to add comments to parameter files when you work with parameter values that might not be immediately clear to someone reading the file.

For example, your website's Bicep template might include a parameter for the URL to access your company's product stock API so that your website can display whether your toys are in stock in your warehouse. The URLs to access the stock API for each environment aren't easy to understand, so they're a good candidate for a comment:

JSON Code

    {
        "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
        "contentVersion": "1.0.0.0",
        "parameters": {
          "productStockCheckApiUrl": {
            "value": "https://x73.mytoycompany.com/e4/j7" // This is the URL to the product stock API in the development environment.
          }
        }
      }
    

Tip

When you work with parameter files and other JSON files that include comments, you usually need to use the _.jsonc_ file extension instead of _.json_. This helps Visual Studio Code and other tools understand that comments are allowed.

## Add descriptions to parameters, variables, and outputs

When you create a parameter, variable, or output, you can apply the `@description()` decorator to help explain its purpose:

Bicep Code

    @description('The Azure region into which the resources should be deployed.')
    param location string = resourceGroup().location
    
    @description('Indicates whether the web application firewall policy should be enabled.')
    var enableWafPolicy = (environmentType == 'prod')
    
    @description('The default host name of the App Service app.')
    output hostName string = app.properties.defaultHostName
    

Descriptions are more powerful than comments because, when someone uses the Visual Studio Code extension for Bicep, the descriptions are shown whenever someone hovers over a symbolic name. Also, when someone uses your Bicep file as a module, they'll see the descriptions you apply to your parameters.

## Add descriptions to resources

It can also be helpful to add descriptions to the resources that you define. You can apply the `@description()` decorator to resources, too.

Additionally, some resources support adding descriptions or other human-readable information into the resource itself. For example, many Azure Policy resources and Azure role-based access control (RBAC) role assignments include a description property, like this:

Bicep Code

    resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
      scope: storageAccount
      name: guid(roleDefinitionId, resourceGroup().id)
      properties: {
        principalType: 'ServicePrincipal'
        roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
        principalId: principalId
        description: 'Contributor access on the storage account is required to enable the application to create blob containers and upload blobs.'
      }
    }
    

It's a good idea to use this property to explain why you've created each role assignment. The description is deployed to Azure with the resource, so anyone who audits your Azure environment's RBAC configuration will immediately understand the purpose of the role assignment.

## Apply resource tags

Comments in your Bicep file don't appear anywhere in your deployed resources. They're there only to help you document your Bicep files. However, there are many situations where you need to track information about your deployed Azure resources, including:

-   Allocating your Azure costs to specific cost centers.
-   Understanding how the data that's contained in databases and storage accounts should be classified and protected.
-   Recording the name of the team or person who's responsible for management of the resource.
-   Tracking the name of the environment that the resource relates to, such as production or development.

Resource _tags_ allow you to store important metadata about resources. You define resource tags in your Bicep code, and Azure stores the information with the resource when it's deployed:

Bicep Code

    resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
      name: storageAccountName
      location: location
      tags: {
        CostCenter: 'Marketing'
        DataClassification: 'Public'
        Owner: 'WebsiteTeam'
        Environment: 'Production'
      }
      sku: {
        name: storageAccountSkuName
      }
      kind: 'StorageV2'
      properties: {
        accessTier: 'Hot'
      }
    }
    

You can query a resource's tags by using tools such as Azure PowerShell and the Azure CLI, and you can see tags on the Azure portal:

![Screenshot of the Azure portal for a storage account, showing the location of tags.](https://learn.microsoft.com/en-us/training/modules/structure-bicep-code-collaboration/media/5-tags-portal.png)

It's common to use the same set of tags for all your resources, so it's often a good idea to define your tags as parameters or variables, and then reuse them on each resource:

Bicep Code

    param tags object = {
      CostCenter: 'Marketing'
      DataClassification: 'Public'
      Owner: 'WebsiteTeam'
      Environment: 'Production'
    }
    
    resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
      tags: tags
    }
    
    resource appServiceApp 'Microsoft.Web/sites@2023-12-01' = {
      tags: tags
    }



# Exercise - Refactor your Bicep file

After you've reviewed your template with your colleagues, you decide to refactor the file to make it easier for them to work with. In this exercise, you apply the best practices you learned in the preceding units.

## Your task

Review the Bicep template that you saved earlier. Think about the advice you've read about how to structure your templates. Try to update your template to make it easier for your colleagues to understand.

In the next sections, there are some pointers to specific parts of the template and some hints about things you might want to change. We provide a suggested solution, but your template might look different, which is perfectly OK!

> 💡 **Tip**
>
>As you work through the refactoring process, it's good to ensure that your Bicep file is valid and that you haven't accidentally introduced any errors. The Bicep extension for Visual Studio Code helps with this. Watch out for any red or yellow squiggly lines below your code, because they indicate an error or a warning. You can also view a list of the problems in your file by selecting **View** > **Problems**.

## Update the parameters

1.  Some parameters in your template aren't clear. For example, consider these parameters:
    
    Bicep Code
    
        @allowed([
          'F1'
          'D1'
          'B1'
          'B2'
          'B3'
          'S1'
          'S2'
          'S3'
          'P1'
          'P2'
          'P3'
          'P4'
        ])
        param skuName string = 'F1'
        
        @minValue(1)
        param skuCapacity int = 1
        
    
    What are they used for?
    
    > 💡 **Tip**
    >
    >If you have a parameter that you're trying to understand, Visual Studio Code can help. Select and hold (or right-click) a parameter name anywhere in your file and select **Find All References**.
    
    Does the template need to specify the list of allowed values for the `skuName` parameter? What resources are affected by choosing different values for these parameters? Are there better names that you can give the parameters?
    
    > 💡 **Tip**
    >
    >When you rename identifiers, be sure to rename them consistently in all parts of your template. This is especially important for parameters, variables, and resources that you refer to throughout your template.
    >
    >Visual Studio Code offers a convenient way to rename symbols: select the identifier that you want to rename, select F2, enter a new name, and then select Enter:
    >
    >![Screenshot from Visual Studio Code that shows how to rename a symbol.](https://learn.microsoft.com/en-us/training/modules/includes/media/rename-symbol.png)
    >
    >These steps rename the identifier and automatically update all references to it.
    
2.  The `managedIdentityName` parameter doesn't have a default value. Could you fix that or, better yet, create the name automatically within the template?
    
3.  Look at the `roleDefinitionId` parameter definition:
    
    Bicep Code
    
        param roleDefinitionId string = 'b24988ac-6180-42a0-ab88-20f7382dd24c'
        
    
    Why is there a default value of `b24988ac-6180-42a0-ab88-20f7382dd24c`? What does that long identifier mean? How would someone else know whether to use the default value or override it? What could you do to improve the identifier? Does it even make sense to have this as a parameter?
    
    Tip
    
    That identifier is the _Contributor_ role definition ID for Azure. How can you use that information to improve the template?
    
4.  When someone deploys the template, how will they know what each parameter is for? Can you add some descriptions to help your template's users?
    

## Add a configuration set

1.  You speak to your colleagues and decide to use specific SKUs for each resource, depending on the environment being deployed. You decide on these SKUs for each of your resources:

| Resource         | SKU for production | SKU for non-production |
|------------------|--------------------|------------------------|
| App Service plan | S1, two instances  | F1, one instance       |
| Storage account  | GRS                | LRS                    |
| SQL database     | S1                 | Basic                  |


2.  Can you use a configuration set to simplify the parameter definitions?
    

## Update the symbolic names

Take a look at the symbolic names for the resources in the template. What could you do to improve them?

1.  Your Bicep template contains resources with a variety of capitalization styles for their symbolic names, such as:
    
    -   `storageAccount` and `webSite`, which use camelCase capitalization.
    -   `roleassignment` and `sqlserver`, which use flat case capitalization.
    -   `sqlserverName_databaseName` and `AppInsights_webSiteName`, which use snake case capitalization.
    
    Can you fix these to use one style consistently?
    
2.  Look at this role assignment resource:
    
    Bicep Code
    
        resource roleassignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
          name: guid(roleDefinitionId, resourceGroup().id)
        
          properties: {
            principalType: 'ServicePrincipal'
            roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
            principalId: msi.properties.principalId
          }
        }
        
    
    Is the symbolic name descriptive enough to help someone else work with this template?
    
    Tip
    
    The reason the identity needs a role assignment is that the web app uses its managed identity to connect to the database server. Does that help you to clarify this in the template?
    
3.  A few resources have symbolic names that don't reflect the current names of Azure resources:
    
    Copy
    
        resource hostingPlan 'Microsoft.Web/serverfarms@2023-12-01' = {
          // ...
        }
        resource webSite 'Microsoft.Web/sites@2023-12-01' = {
          // ...
        }
        resource msi 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
          // ...
        }
        
    
    Managed identities used to be called _MSIs_, App Service plans used to be called _hosting plans_, and App Service apps used to be called _websites_.
    
    Can you update these to the latest names to avoid confusion in the future?
    

## Simplify the blob container definitions

1.  Look at how the blob containers are defined:
    
    Bicep Code
    
        resource container1 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
          parent: storageAccount::blobServices
          name: container1Name
        }
        
        resource productmanuals 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
          name: '${storageAccount.name}/default/${productmanualsName}'
        }
        
    
    One of them uses the `parent` property, and the other doesn't. Can you fix these to be consistent?
    
2.  The blob container names won't change between environments. Do you think the names need to be specified by using parameters?
    
3.  There are two blob containers. Could they be deployed by using a loop?
    

## Update the resource names

1.  There are some parameters that explicitly set resource names:
    
    Bicep Code
    
        param managedIdentityName string
        param roleDefinitionId string = 'b24988ac-6180-42a0-ab88-20f7382dd24c'
        param webSiteName string = 'webSite${uniqueString(resourceGroup().id)}'
        param container1Name string = 'productspecs'
        param productmanualsName string = 'productmanuals'
        
    
    Is there another way you could do this?
    
    > ⚠️ **Caution**
    >
    >Remember that resources can't be renamed once they're deployed. When you modify templates that are already in use, be careful when you change the way the template creates resource names. If the template is redeployed and the resource has a new name, Azure will create another resource. It might even delete the old resource if you deploy it in _Complete_ mode.
    >
    >You don't need to worry about this here, because it's only an example.
    
2.  Your SQL logical server's resource name is set using a variable, even though it needs a globally unique name:
    
    Bicep Code
    
        var sqlserverName = 'toywebsite${uniqueString(resourceGroup().id)}'
        
    
    How could you improve this?
    

## Update dependencies and child resources

1.  Here's one of your resources, which includes a `dependsOn` property. Does it really need it?
    
    Bicep Code
    
        resource sqlserverName_AllowAllAzureIPs 'Microsoft.Sql/servers/firewallRules@2023-08-01-preview' = {
          name: '${sqlserver.name}/AllowAllAzureIPs'
          properties: {
            endIpAddress: '0.0.0.0'
            startIpAddress: '0.0.0.0'
          }
          dependsOn: [
            sqlserver
          ]
        }
        
    
2.  Notice how these child resources are declared in your template:
    
    Bicep Code
    
        resource sqlserverName_databaseName 'Microsoft.Sql/servers/databases@2023-08-01-preview' = {
          name: '${sqlserver.name}/${databaseName}'
          location: location
          sku: {
            name: 'Basic'
          }
          properties: {
            collation: 'SQL_Latin1_General_CP1_CI_AS'
            maxSizeBytes: 1073741824
          }
        }
        
        resource sqlserverName_AllowAllAzureIPs 'Microsoft.Sql/servers/firewallRules@2023-08-01-preview' = {
          name: '${sqlserver.name}/AllowAllAzureIPs'
          properties: {
            endIpAddress: '0.0.0.0'
            startIpAddress: '0.0.0.0'
          }
          dependsOn: [
            sqlserver
          ]
        }
        
    
    How could you modify how these resources are declared? Are there any other resources in the template that should be updated too?
    

## Update property values

1.  Take a look at the SQL database resource properties:
    
    Bicep Code
    
        resource sqlserverName_databaseName 'Microsoft.Sql/servers/databases@2023-08-01-preview' = {
          name: '${sqlserver.name}/${databaseName}'
          location: location
          sku: {
            name: 'Basic'
          }
          properties: {
            collation: 'SQL_Latin1_General_CP1_CI_AS'
            maxSizeBytes: 1073741824
          }
        }
        
    
    Does it make sense to hard-code the SKU's `name` property value? And what are those weird-looking values for the `collation` and `maxSizeBytes` properties?
    
    Tip
    
    The `collation` and `maxSizeBytes` properties are set to the default values. If you don't specify the values yourself, the default values will be used. Does that help you to decide what to do with them?
    
2.  Can you change the way the storage connection string is set so that the complex expression isn't defined inline with the resource?
    
    Bicep Code
    
        resource webSite 'Microsoft.Web/sites@2023-12-01' = {
          name: webSiteName
          location: location
          properties: {
            serverFarmId: hostingPlan.id
            siteConfig: {
              appSettings: [
                {
                  name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
                  value: AppInsights_webSiteName.properties.InstrumentationKey
                }
                {
                  name: 'StorageAccountConnectionString'
                  value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
                }
              ]
            }
          }
          identity: {
            type: 'UserAssigned'
            userAssignedIdentities: {
              '${msi.id}': {}
            }
          }
        }
        
    

## Order of elements

1.  Are you happy with the order of the elements in the file? How could you improve the file's readability by moving the elements around?
    
2.  Take a look at the `databaseName` variable. Does it belong where it is now?
    
    Bicep Code
    
        var databaseName = 'ToyCompanyWebsite'
        resource sqlserverName_databaseName 'Microsoft.Sql/servers/databases@2023-08-01-preview' = {
          name: '${sqlserver.name}/${databaseName}'
          location: location
          sku: {
            name: 'Basic'
          }
          properties: {
            collation: 'SQL_Latin1_General_CP1_CI_AS'
            maxSizeBytes: 1073741824
          }
        }
        
    
3.  Did you notice the commented-out resource, `webSiteConnectionStrings`? Do you think that needs to be in the file?
    

## Add comments, tags, and other metadata

Think about anything in the template that might not be obvious, or that needs additional explanation. Can you add comments to make it clearer for others who might open the file in the future?

1.  Take a look at the `webSite` resource's `identity` property:
    
    Bicep Code
    
        resource webSite 'Microsoft.Web/sites@2023-12-01' = {
          name: webSiteName
          location: location
          properties: {
            serverFarmId: hostingPlan.id
            siteConfig: {
              appSettings: [
                {
                  name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
                  value: AppInsights_webSiteName.properties.InstrumentationKey
                }
                {
                  name: 'StorageAccountConnectionString'
                  value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
                }
              ]
            }
          }
          identity: {
            type: 'UserAssigned'
            userAssignedIdentities: {
              '${msi.id}': {}
            }
          }
        }
        
    
    That syntax is strange, isn't it? Do you think this needs a comment to help explain it?
    
2.  Look at the role assignment resource:
    
    Bicep Code
    
        resource roleassignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
          name: guid(roleDefinitionId, resourceGroup().id)
        
          properties: {
            principalType: 'ServicePrincipal'
            roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
            principalId: msi.properties.principalId
          }
        }
        
    
    The resource name uses the `guid()` function. Would it help to explain why?
    
3.  Can you add a description to the role assignment?
    
4.  Can you add a set of tags to each resource?
    

## Suggested solution

Here's an example of how you might refactor the template. Your template might not look exactly like this, because your style might be different.

Bicep Code
```bicep
    @description('The location into which your Azure resources should be deployed.')
    param location string = resourceGroup().location
    
    @description('Select the type of environment you want to provision. Allowed values are Production and Test.')
    @allowed([
      'Production'
      'Test'
    ])
    param environmentType string
    
    @description('A unique suffix to add to resource names that need to be globally unique.')
    @maxLength(13)
    param resourceNameSuffix string = uniqueString(resourceGroup().id)
    
    @description('The administrator login username for the SQL server.')
    param sqlServerAdministratorLogin string
    
    @secure()
    @description('The administrator login password for the SQL server.')
    param sqlServerAdministratorLoginPassword string
    
    @description('The tags to apply to each resource.')
    param tags object = {
      CostCenter: 'Marketing'
      DataClassification: 'Public'
      Owner: 'WebsiteTeam'
      Environment: 'Production'
    }
    
    // Define the names for resources.
    var appServiceAppName = 'webSite${resourceNameSuffix}'
    var appServicePlanName = 'AppServicePLan'
    var sqlServerName = 'sqlserver${resourceNameSuffix}'
    var sqlDatabaseName = 'ToyCompanyWebsite'
    var managedIdentityName = 'WebSite'
    var applicationInsightsName = 'AppInsights'
    var storageAccountName = 'toywebsite${resourceNameSuffix}'
    var blobContainerNames = [
      'productspecs'
      'productmanuals'
    ]
    
    @description('Define the SKUs for each component based on the environment type.')
    var environmentConfigurationMap = {
      Production: {
        appServicePlan: {
          sku: {
            name: 'S1'
            capacity: 2
          }
        }
        storageAccount: {
          sku: {
            name: 'Standard_GRS'
          }
        }
        sqlDatabase: {
          sku: {
            name: 'S1'
            tier: 'Standard'
          }
        }
      }
      Test: {
        appServicePlan: {
          sku: {
            name: 'F1'
            capacity: 1
          }
        }
        storageAccount: {
          sku: {
            name: 'Standard_LRS'
          }
        }
        sqlDatabase: {
          sku: {
            name: 'Basic'
          }
        }
      }
    }
    
    @description('The role definition ID of the built-in Azure \'Contributor\' role.')
    var contributorRoleDefinitionId = 'b24988ac-6180-42a0-ab88-20f7382dd24c'
    var storageAccountConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
    
    resource sqlServer 'Microsoft.Sql/servers@2023-08-01-preview' = {
      name: sqlServerName
      location: location
      tags: tags
      properties: {
        administratorLogin: sqlServerAdministratorLogin
        administratorLoginPassword: sqlServerAdministratorLoginPassword
        version: '12.0'
      }
    }
    
    resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-08-01-preview' = {
      parent: sqlServer
      name: sqlDatabaseName
      location: location
      sku: environmentConfigurationMap[environmentType].sqlDatabase.sku
      tags: tags
    }
    
    resource sqlFirewallRuleAllowAllAzureIPs 'Microsoft.Sql/servers/firewallRules@2023-08-01-preview' = {
      parent: sqlServer
      name: 'AllowAllAzureIPs'
      properties: {
        endIpAddress: '0.0.0.0'
        startIpAddress: '0.0.0.0'
      }
    }
    
    resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
      name: appServicePlanName
      location: location
      sku: environmentConfigurationMap[environmentType].appServicePlan.sku
      tags: tags
    }
    
    resource appServiceApp 'Microsoft.Web/sites@2023-12-01' = {
      name: appServiceAppName
      location: location
      tags: tags
      properties: {
        serverFarmId: appServicePlan.id
        siteConfig: {
          appSettings: [
            {
              name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
              value: applicationInsights.properties.InstrumentationKey
            }
            {
              name: 'StorageAccountConnectionString'
              value: storageAccountConnectionString
            }
          ]
        }
      }
      identity: {
        type: 'UserAssigned'
        userAssignedIdentities: {
          '${managedIdentity.id}': {} // This format is required when working with user-assigned managed identities.
        }
      }
    }
    
    resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
      name: storageAccountName
      location: location
      sku: environmentConfigurationMap[environmentType].storageAccount.sku
      kind: 'StorageV2'
      properties: {
        accessTier: 'Hot'
      }
    
      resource blobServices 'blobServices' existing = {
        name: 'default'
    
        resource containers 'containers' = [for blobContainerName in blobContainerNames: {
          name: blobContainerName
        }]
      }
    }
    
    @description('A user-assigned managed identity that is used by the App Service app to communicate with a storage account.')
    resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview'= {
      name: managedIdentityName
      location: location
      tags: tags
    }
    
    @description('Grant the \'Contributor\' role to the user-assigned managed identity, at the scope of the resource group.')
    resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
      name: guid(contributorRoleDefinitionId, resourceGroup().id) // Create a GUID based on the role definition ID and scope (resource group ID). This will return the same GUID every time the template is deployed to the same resource group.
      properties: {
        principalType: 'ServicePrincipal'
        roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', contributorRoleDefinitionId)
        principalId: managedIdentity.properties.principalId
        description: 'Grant the "Contributor" role to the user-assigned managed identity so it can access the storage account.'
      }
    }
    
    resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
      name: applicationInsightsName
      location: location
      kind: 'web'
      tags: tags
      properties: {
        Application_Type: 'web'
      }
    }
```    

Tip

If you're working with your colleagues using GitHub or Azure Repos, this would be a great time to submit a _pull request_ to integrate your changes into the main branch. It's a good idea to submit pull requests after you do a piece of refactoring work.



# Module assessment

Your colleagues have asked you to help them work with this template:

Bicep Code
```bicep
    param number int
    param name string
    param name2 string
    
    var location = 'australiaeast'
    
    resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' = {
      name: name
      location: location
      properties: {
        addressSpace:{
          addressPrefixes:[
            '10.0.0.0/16'
          ]
        }
        subnets: [for i in range(1, number): {
          name: 'subnet-${i}'
          properties: {
            addressPrefix: '10.0.${i}.0/24'
          }
        }]
      }
    }
    
    resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
      name: name2
      location: location
      kind: 'StorageV2'
      sku: {
        name: 'Standard_LRS'
      }
    }
```    

You're refactoring the template to make it easier for other people in your organization to use.

1.

Which of these steps should you take?

- -> Rename the `number`, `name`, and `name2` parameters.

- Create a module for each resource.

- Create a new output to pass the storage account key back to the user.

2.

You want to ensure that your template's users provide valid inputs for the `number` parameter. How should you do this?

- -> Apply parameter decorators.

- Apply Azure role-based access control (RBAC) on your deployment scope.

- Hard-code as many values into templates as possible.

3.

What is one of the benefits of using _configuration sets_ for your Bicep templates?

- You can expose all of your resources' properties to your template's users as parameters.

- -> You can abstract the internal complexity of the template by providing a simple set of options.

- You can structure your template and group elements in any order.



# Summary

You agreed to share your Bicep template with your colleagues, but as you began reviewing it together, it became clear that they were confused about what it was doing. You wanted to refactor the template to make it easier for your colleagues to understand, reuse, and modify.

In this module, you learned how to write and structure your Bicep code to support collaboration. You refactored your template to improve the parameters and resource names. You restructured it to make it easier to understand and use. And you added explanatory documentation in the form of comments and metadata.

Along the way, you learned how the Bicep extension for Visual Studio Code can help you refactor and reorganize your Bicep code. The changes you made to your Bicep code meant that your colleagues were able to use your template, and they met their deadline!

When you're working individually, it's easy to forget to structure your Bicep code so that it's understandable to others. But by establishing good habits, applying best practices, and investing just a little time, you can make it easy for your colleagues to deploy your template and to build on your work.

You're also making it easier on yourself when you need to use your Bicep code in the future.

Tip

As you continue to use Bicep, you'll benefit from understanding the [Bicep patterns](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/patterns-configuration-set). The patterns provide proven solutions to some of the common scenarios Bicep users face.

You should also be familiar with [Bicep scenarios](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/scenarios-rbac), which provide guidance on how to build Bicep files for specific types of Azure resources.

## References

-   [Best practices for Bicep](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/best-practices)
-   [Cloud Adoption Framework guidance on naming and tagging](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging)
-   [Azure resource name rules](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules)



