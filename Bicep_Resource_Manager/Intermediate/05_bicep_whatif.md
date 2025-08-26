# Preview Azure deployment changes by using what-if
[Link](https://learn.microsoft.com/en-us/training/modules/arm-template-whatif/)  


# Introduction

Deployments that use Azure Resource Manager templates (ARM templates) and Bicep files result in a series of changes to your Azure environment. In this module, you learn how to preview changes before you execute a deployment.

## Example scenario

Suppose you help to manage the Azure environment at a toy company. One of your colleagues has asked you to help update some templates that you previously created to deploy a virtual network. Before you deploy your updated template, you want to confirm exactly what changes Azure will make. So you decide to evaluate how to preview changes in your deployments.

## What will we be doing?

In this module, you gain an understanding of the what-if operation for Azure Resource Manager. You also learn about the modes that you can use for your deployments to Azure.

> 📝 **Note**
>
>Bicep is a language for defining your Azure resources. It has a simpler authoring experience than JSON, along with other features that help improve the quality of your infrastructure as code. We recommend that anyone new to infrastructure as code on Azure use Bicep instead of JSON. To learn about Bicep, see the [Fundamentals of Bicep](https://learn.microsoft.com/en-us/training/paths/fundamentals-bicep/) learning path.

## What is the main goal?

By the end of this module, you're able to preview changes to your Azure environment before you deploy them by using the what-if operation.

## Prerequisites

You should be familiar with:

-   Creating and deploying basic ARM templates, using either Bicep or JSON.
-   Azure, including the Azure portal, subscriptions, resource groups, and resource definitions.

To follow along with the exercises in the module, you need:

-   [Visual Studio Code](https://code.visualstudio.com/) installed locally.
-   Either:
    -   The [Bicep extension for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep) installed locally.
    -   The [Azure Resource Manager Tools for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=msazurermtools.azurerm-vscode-tools) extension installed locally.
-   Either:
    -   The latest [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) tools installed locally.
    -   The latest [Azure PowerShell](https://learn.microsoft.com/en-us/powershell/azure/install-az-ps) version installed locally.



