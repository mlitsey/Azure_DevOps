# Review Azure infrastructure changes by using Bicep and pull requests
[Link](https://learn.microsoft.com/en-us/training/modules/review-azure-infrastructure-changes-using-bicep-pull-requests/)  



# Introduction

When you work on Bicep code, the main branch of your Git repository becomes the source of truth. The main branch incorporates the latest changes from your whole team, and it usually reflects the state of your Azure environment.

It's important that the changes that are merged into your repository's main branch are reviewed. In this module, you'll learn how to protect your main branch by using other branches and pull request reviews.

## Example scenario

Suppose you're responsible for deploying and configuring the Azure infrastructure at a toy company. Your team is growing, and it's getting more difficult to keep track of all the changes that everyone is making.

Recently, a new team member accidentally changed an important Bicep file on your repository's main branch. That change caused a problem in your organization's production environment. You talk to your team and decide that it's time for you to start reviewing code changes before they're merged and deployed.

Now, you need to make a change to the way your website processes orders. You need to add a message queue so that your website can post messages whenever a customer places an order for a toy. A back-end system, built by another team, will pick up these messages and process the orders later. You need to ensure that you don't start sending messages to the queue until the other team is ready.

You decide that this is a great opportunity to try out a new process. You'll use pull requests to control how your Bicep changes are merged. Code will be written by the author, reviewed by a reviewer, and then merged to a Git repository before it's deployed to Azure.

![Diagram that shows a Bicep code review process of authoring, reviewing and merging.](https://learn.microsoft.com/en-us/training/modules/review-azure-infrastructure-changes-using-bicep-pull-requests/media/1-process.png)

## What will we be doing?

In this module, you'll learn how to protect the code on your main branch by enforcing a change-control process through pull requests. You'll learn about branching strategies, and how to prevent your team from making changes to the main branch unless they've followed the correct process. You'll also learn how to use pull requests to review your code.

## What is the main goal?

After you complete this module, you'll be able to use a branching strategy for your own Bicep code. You'll also know how to create, review, and merge pull requests. You'll understand important elements to look for when you review a pull request for Bicep code.



# Understand branching

When you build Bicep templates and work within a Git repository, all of your team's changes are eventually merged into your repository's main branch. It's important to protect the main branch so that no unwanted changes are deployed to your production environment. However, you also want your contributors to be able to work flexibly, collaborate with your team, and try out ideas easily.

In this unit, you'll learn about branching strategies and how to protect the main branch. You'll also learn how to set up a review process for your branches.

## Why do you want to protect the main branch?

The main branch is the source of truth for what gets deployed to your Azure environments. For many solutions, you'll have multiple environments, such as _development_, _quality assurance (QA)_, and _production_. In other scenarios, you might have only a production environment. Regardless of how many environments you use, the main branch is the branch to which your team members contribute. Their changes ultimately land on the main branch.

A typical process might be the following:

1.  A team member clones your shared repository.
2.  They make local changes on a branch in their own local copy of the repository.
3.  When they're finished with their changes, they merge these changes in their local repository's main branch.
4.  They push these changes to the remote repository's main branch.
5.  In some scenarios, the remote repository's push triggers an automated pipeline to verify, test, and deploy the code. You'll learn more about pipelines in other Microsoft Learn modules.

The following diagram illustrates this process:

![Diagram that shows the process of making local changes, pushing changes to the remote main branch, and triggering a pipeline.](https://learn.microsoft.com/en-us/training/modules/review-azure-infrastructure-changes-using-bicep-pull-requests/media/2-basic-process.png)

Suppose the team member's changes introduced a subtle bug. After the complete process runs, the bug is now on the main branch of the project and gets deployed to production. You might not discover it until you try to deploy it and get an error. Or, for other types of bugs, the deployment might succeed, but cause subtle problems later.

In another scenario, suppose a team member is working on a feature and pushes half of the feature's finished work to the shared repository's main branch. You now have changes on the main branch that aren't finished or tested. These changes probably shouldn't be deployed to your production environment. Deployments to production might need to be blocked until the feature is finished. If newly finished features are on the main branch, you might not be able to deploy them to your customers.

Tip

These problems are particularly difficult for large teams, where multiple people contribute to the same code, but the guidance in this module is valuable as soon as you collaborate with more than one person. The guidance is valuable even when it's just you working on a project, and you're working on multiple features at the same time.

A better way of working is to keep your changes separate while you work on them. You can then have another team member review any changes before they're merged into the main branch of your team's shared repository. This process helps your team make an informed decision on a change before you approve it to be merged.

## Feature branches

A _feature branch_ indicates a new piece of work you're starting. The work might be a configuration change to a resource defined in your Bicep file, or a new set of resources that you need to deploy. Every time you start a new piece of work, you create a new feature branch.

You create a feature branch from the main branch. When you create a branch, you ensure that you're starting from the current state of your Azure environment. You then make all your necessary changes.

Because all of the code changes are committed to the feature branch, they don't interfere with the repository's main branch. If somebody else on your team needs to make an urgent change to the main branch, they can do that on another feature branch that's independent of yours.

You can collaborate on feature branches, too. By publishing and pushing your feature branch to the shared repository, you and your team members can work together on a change. You can also hand over a feature to someone else to complete when you go on vacation.

### Update your feature branches

While your feature branch is underway, other features might be merged into your repository's main branch. The result is that your feature branch and your project's main branch will drift apart. The further they drift apart, the more difficult it becomes to merge the two branches again at a later point, and the more merge conflicts you might encounter.

You should update your feature branch regularly so that you incorporate any changes that have been made to the repository's main branch. It's also a good idea to update your feature branch before you start to merge the feature branch back into the main branch. This way, you make sure that your new changes can be merged into the main branch easily.

>Tip
>
>Merge the main branch into your feature branch often.

### Use small, short-lived branches

Aim for short-lived feature branches. This approach helps you avoid merge conflicts by reducing the amount of time that your branches might get out of sync. This approach also makes it easier for your colleagues to understand the changes you've made, which is helpful when you need someone to review your changes.

Split up large pieces of work into smaller pieces and create a feature branch for each one. The bigger the feature, the longer someone needs to work on it, and the longer the feature branch will live. You can deploy the smaller changes to production as you merge each feature branch and gradually build up the broader work.

Imagine that you're making some changes to a set of Bicep code. You're moving some resource definitions into modules. You also need to add some new resources to your Bicep files. It might be a good idea to do all of your module refactoring first, on its own branch. After the modules are merged, you can start to work on the additions to your Bicep files. By separating your changes, you keep each change—and its branch—small and easy to understand.

When you work in this way, it can be helpful to use the `if` keyword to disable deploying resources until they're ready. The following example code shows how you would use the `if` keyword to create a Bicep file that defines a storage account but disables the storage account's deployment until you're done with all of the changes.

Bicep Code

    @description('Specifies whether the storage account is ready to be deployed.')
    param storageAccountReady bool = false
    
    resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = if (storageAccountReady) {
      name: storageAccountName
      location: location
      kind: 'StorageV2'
      sku: {
        name: 'Premium_LRS'
      }
    }
    

You can use parameters to specify different values for the `storageAccountReady` variable in different environments. For example, you might set the parameter value to `true` for your test environment and `false` for your production environment. That way, you can try out the new storage account in your test environment.

>Note
>
>When it's time to enable the feature in production, remember that you need to take the following steps for your change to take effect:
>
>1.  Change the parameter value.
>2.  Redeploy your Bicep file.

### Merging feature branches

When you've finished working on a feature branch, you need to merge it into your repository's main branch. It's a good practice to review the changes that were made on the feature branch before merging. Pull requests enable you to review your code. You'll learn more about pull requests later in this module.

### Branch protections

In GitHub, you can configure _branch protections_ for the shared repository's main branch. Branch protections enforce rules like:

-   No change can be merged into the main branch except through a pull request.
-   Changes need to be reviewed by at least two other people.

If somebody tries to push a commit directly to a protected branch, the push fails. You'll learn how to apply branch protections in the next unit.

### Branch policies

In Azure DevOps, you can configure _branch policies_ for the shared repository's main branch. Branch policies enforce rules like:

-   No change can be merged into the main branch except through a pull request.
-   Changes need to be reviewed by at least two other people.

If somebody tries to push a commit directly to a protected branch, the push fails. You'll learn how to apply branch policies in the next unit.

## Other branching strategies

When you collaborate on your Bicep code, you can use various branching strategies. Each branching strategy has benefits and drawbacks.

The process you've learned about so far is a version of the _trunk-based development_ strategy. In this branching strategy, work is done on short-lived feature branches and is then merged into a single main branch. You might automatically deploy the contents of the shared repository's main branch to production every time a change is merged, or you might batch changes and release them on a schedule, like every week. Trunk-based development is easy to understand, and it enables collaboration without much overhead.

Some teams separate the work that they've completed from the work that they've deployed to production. They use a long-lived _development_ branch as the target for merging their feature branches. They merge the _development_ branch into their _main_ branch when they release changes to production.

Some other branching strategies require you to create _release branches_. When you have a set of changes ready to deploy to production, you create a release branch with the changes to deploy. These strategies can make sense when you deploy your Azure infrastructure on a regular cadence, or when you're integrating your changes with many other teams.

Other branching strategies include Gitflow, GitHub Flow, and GitLab Flow. Some teams use GitHub Flow or GitLab Flow because it enables separating work from different teams, along with separating urgent bug fixes from other changes. These processes can also enable you to separate your commits into different releases of your solution, which is called _cherry picking_. However, they require more management to ensure that your changes are compatible with each other. This module's Summary section provides links to more information on these branching strategies.

The branching strategy that's right for your team depends on the way your team works, collaborates, and releases its changes. It's a good idea to start from a simple process, like trunk-based development. If you find that your team can't work effectively by using this process, gradually introduce other layers of branching, or adopt a branching strategy; but be aware that as you add more branches, managing your repository becomes more complex.

>Tip
>
>Regardless of the branching strategy that you use, it's good to use branch policies to protect the main branch and to use pull requests to review your changes. Other branching strategies also introduce important branches that you should protect.

In this module, we use trunk-based development with feature branches, because it's easy to use.



# Exercise - Protect your main branch

Your team is working on a Bicep template that already contains a website and a database. You've deployed the components to your production environment. Now, you need to update your Bicep template to add your order processing queue.

In this exercise, you'll create a feature branch for your change. You'll also protect your main branch and only allow changes to be merged to the main branch after they've been reviewed. Before that, though, you need to make sure that your environment is set up to complete the rest of this module.

During the process, you'll:

-   Set up a GitHub repository for this module.
-   Clone the repository to your computer.
-   Add branch protection to your repository's main branch.
-   Create a local feature branch for your change.
-   Try to merge your feature branch into main.

-   Set up an Azure DevOps project for this module.
-   Clone the project's repository to your computer.
-   Add branch policies to your repository's main branch.
-   Create a local feature branch for your change.
-   Try to merge your feature branch into main.

## Get the GitHub repository

Here, you make sure that your GitHub repository is set up to complete the rest of this module. You set it up by creating a new repository based on a template repository. The template repository contains the files that you need to get started for this module.

### Start from the template repository

Run a template that sets up your GitHub repository.

[Run the template](https://github.com/MicrosoftDocs/mslearn-review-azure-infrastructure-changes-using-bicep-pull-requests)

On the GitHub site, follow these steps to create a repository from the template:

1.  Select **Use this template** > **Create a new repository**.
    
    ![Screenshot of the GitHub interface that shows the template repo, with the button for using the current template highlighted.](https://learn.microsoft.com/en-us/training/modules/review-azure-infrastructure-changes-using-bicep-pull-requests/media/3-template.png)
    
2.  Enter a name for your new project, such as _toy-website-review_.
    
3.  Select the **Public** option.
    
    When you create your own repositories, you might want to make them private. In this module, you'll work with features of GitHub that work only with public repositories and with GitHub Enterprise accounts.
    
4.  Select **Create repository from template**.
    
    ![Screenshot of the GitHub interface that shows the repo creation page.](https://learn.microsoft.com/en-us/training/modules/review-azure-infrastructure-changes-using-bicep-pull-requests/media/3-repo-settings.png)
    

## Get the Azure DevOps project

Here, you make sure that your Azure DevOps organization is set up to complete the rest of this module. Run a template that sets up your Azure DevOps organization.

1.  [Get and run the ADOGenerator project](https://github.com/microsoft/AzDevOpsDemoGenerator/blob/main/docs/RunApplication.md) in Visual Studio or the IDE of your choice.
    
2.  When prompted to **Enter the template number from the list of templates**, enter **44** for **Review Azure infrastructure changes by using Bicep and pull requests**, then press **Enter**.
    
3.  Choose your authentication method. You can [set up and use a Personal Access Token (PAT)](https://learn.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate#create-a-pat) or use device login.
    
    Note
    
    If you set up a PAT, make sure to authorize the necessary [scopes](https://learn.microsoft.com/en-us/azure/devops/integrate/get-started/authentication/oauth#scopes). For this module, you can use **Full access**, but in a real-world situation, you should ensure you grant only the necessary scopes.
    
4.  Enter your Azure DevOps organization name, then press **Enter**.
    
5.  If prompted, enter your Azure DevOps PAT, then press **Enter**.
    
6.  Enter a project name such as _toy-website-review_, then press **Enter**.
    
7.  Once your project is created, go to your Azure DevOps organization in your browser (at `https://dev.azure.com/<your-organization-name>/`) and select the project.
    

## Clone the repository

You now have a copy of the template repository in your own account. Clone this repository locally so you can start working in it.

1.  Select **Code**, and then select the **Copy** icon.
    
    ![Screenshot of the GitHub interface that shows the new repository, with the repository U R L copy button highlighted.](https://learn.microsoft.com/en-us/training/modules/review-azure-infrastructure-changes-using-bicep-pull-requests/media/3-github-repository-clipboard.png)
    
2.  Open Visual Studio Code.
    
3.  Open a Visual Studio Code terminal window by selecting **Terminal** > **New Terminal**. The window usually opens at the bottom of the screen.
    
4.  In the terminal, go to the directory where you want to clone the GitHub repository on your local computer. For example, to clone the repository to the _toy-website-review_ folder, run the following command:
    
    Bash Code
    
        cd toy-website-review
        
    
5.  Type `git clone` and paste the URL that you copied earlier, and then run the command. The command looks like this:
    
    Bash Code
    
        git clone https://github.com/mygithubuser/toy-website-review.git
        
    
6.  Reopen Visual Studio Code in the repository folder by running the following command in the Visual Studio Code terminal:
    
    Bash Code
    
        code -r toy-website-review
        
    

You now have a project in your own account. Clone this repository locally so you can start working in it.

1.  Select **Repos** > **Files**.
    
    ![Screenshot of Azure DevOps that shows the Repos menu, with Files highlighted.](https://learn.microsoft.com/en-us/training/modules/review-azure-infrastructure-changes-using-bicep-pull-requests/media/3-repos-files.png)
    
2.  Select **Clone**.
    
    ![Screenshot of Azure DevOps that shows the repository, with the Clone button highlighted.](https://learn.microsoft.com/en-us/training/modules/review-azure-infrastructure-changes-using-bicep-pull-requests/media/3-repos-clone.png)
    
3.  If you're using macOS, you need a special password to clone the Git repository. Select **Generate Git credentials** and copy the displayed username and password to somewhere safe.
    
4.  Select **Clone in VS Code**. If you're prompted to allow Visual Studio Code to open, select **Open**.
    
    ![Screenshot of Azure DevOps that shows the repository settings, with the button for cloning in Visual Studio Code highlighted.](https://learn.microsoft.com/en-us/training/modules/review-azure-infrastructure-changes-using-bicep-pull-requests/media/3-repos-clone-visual-studio-code.png)
    
5.  Create a folder to use for the repository, and then choose **Select Repository Location**.
    
6.  You're using this repository for the first time, so you're prompted to sign in.
    
    -   If you're using Windows, enter the same credentials that you used to sign in to Azure DevOps earlier in this exercise.
        
    -   If you're using macOS, enter the Git username and password that you generated a few moments ago.
        
7.  Visual Studio Code prompts you to open the repository. Select **Open**.
    
    ![Screenshot of Visual Studio Code that shows a prompt to open the cloned repository, with the Open button highlighted.](https://learn.microsoft.com/en-us/training/modules/includes/media/open-cloned-repo.png)
    

## Add branch protections

Configure your Git repository to prevent direct pushes to the main branch.

1.  In your browser, select **Settings**.
    
2.  Select **Branches**.
    
3.  Select **Add branch protection rule**.
    
    ![Screenshot of GitHub that shows the page for adding branch protection rules, with the button for adding a rule highlighted.](https://learn.microsoft.com/en-us/training/modules/review-azure-infrastructure-changes-using-bicep-pull-requests/media/3-github-branch-protections.png)
    
4.  In the **Branch name pattern** text box, enter _main_.
    
5.  Select **Require a pull request before merging**.
    
    Clear **Require approvals**. Normally, you'd select this option. But in this example, you're going to merge your own pull request, and the **Require approvals** option prevents you from doing so.
    
6.  Select **Do not allow bypassing the above settings**.
    
    You select this setting as an example to show how `git push` to `main` fails later in this exercise. In a production environment, you might not want to restrict direct merges to `main` for administrators or repository owners.
    
7.  Near the bottom of the page, select **Create**.
    
    ![Screenshot of GitHub that shows the Create button.](https://learn.microsoft.com/en-us/training/modules/review-azure-infrastructure-changes-using-bicep-pull-requests/media/3-github-branch-protections-add.png)
    
    GitHub might ask you to sign in again to confirm your identity.
    

## Add branch policies

Configure your Git repository to prevent direct pushes to the main branch.

1.  In your browser, go to **Repos** > **Branches**.
    
2.  Hover over the **main** branch, and select the three dots.
    
3.  Select **Branch policies**.
    
    ![Screenshot of Azure DevOps that shows the list of branches, with the context menu displayed and the menu item for branch policies highlighted.](https://learn.microsoft.com/en-us/training/modules/review-azure-infrastructure-changes-using-bicep-pull-requests/media/3-repos-branch-policies.png)
    
4.  In the **Branch policies** window, change the **Require a minimum number of reviewers** setting to **On**.
    
5.  Change the minimum number of reviewers to **1**, and select the **Allow requestors to approve their own changes** option.
    
    ![Screenshot of Azure DevOps that shows the branch policies page for the main branch.](https://learn.microsoft.com/en-us/training/modules/review-azure-infrastructure-changes-using-bicep-pull-requests/media/3-repos-branch-policy-main.png)
    
    Note
    
    Here, you enable the **Allow requestors to approve their own changes** option. In these exercises, you're working on your own, so you need to both create and approve your changes. But in a real team environment, you might not want to enable this option.
    

## Create a local feature branch

1.  In the Visual Studio Code terminal, run the following statement:
    
    Bash Code
    
        git checkout -b add-orders-queue
        
    
    This command creates a new feature branch for you to work from.
    
2.  Open the _main.bicep_ file in the _deploy_ folder.
    
    ![Screenshot of Visual Studio Code that shows the main dot bicep file in the deploy folder.](https://learn.microsoft.com/en-us/training/modules/review-azure-infrastructure-changes-using-bicep-pull-requests/media/3-visual-studio-code-main-bicep.png)
    
3.  Below the parameters, add a new variable for the name of the queue:
    
    Bicep Code
    
        var storageAccountSkuName = (environmentType == 'prod') ? 'Standard_GRS' : 'Standard_LRS'
        var processOrderQueueName = 'processorder'
        
    
4.  Within the storage account resource, add the queue as a nested child resource:
    
    Bicep Code
    
        resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
          name: storageAccountName
          location: location
          sku: {
            name: storageAccountSkuName
          }
          kind: 'StorageV2'
          properties: {
            accessTier: 'Hot'
          }
        
          resource queueServices 'queueServices' existing = {
            name: 'default'
        
            resource processOrderQueue 'queues' = {
              name: processOrderQueueName
            }
          }
        }
        
    
5.  In the `appService` module definition, add the storage account and queue names as parameters:
    
    Bicep Code
    
        module appService 'modules/appService.bicep' = {
          name: 'appService'
          params: {
            location: location
            appServiceAppName: appServiceAppName
            storageAccountName: storageAccount.name
            processOrderQueueName: storageAccount::queueServices::processOrderQueue.name
            environmentType: environmentType
          }
        }
        
    
    This code enables the application to find the queue where it will send messages.
    
6.  Save the _main.bicep_ file.
    
7.  Open the _appService.bicep_ file in the _deploy/modules_ folder.
    
8.  Near the top of the _appService.bicep_ file, add new parameters for the storage account and queue names:
    
    Bicep Code
    
        @description('The Azure region into which the resources should be deployed.')
        param location string
        
        @description('The name of the App Service app to deploy. This name must be globally unique.')
        param appServiceAppName string
        
        @description('The name of the storage account to deploy. This name must be globally unique.')
        param storageAccountName string
        
        @description('The name of the queue to deploy for processing orders.')
        param processOrderQueueName string
        
        @description('The type of the environment. This must be nonprod or prod.')
        @allowed([
          'nonprod'
          'prod'
        ])
        param environmentType string
        
    
9.  Update the `appServiceApp` resource to propagate the storage account and queue names to the application's environment variables:
    
    Bicep Code
    
        resource appServiceApp 'Microsoft.Web/sites@2024-04-01' = {
          name: appServiceAppName
          location: location
          properties: {
            serverFarmId: appServicePlan.id
            httpsOnly: true
            siteConfig: {
              appSettings: [
                {
                  name: 'StorageAccountName'
                  value: storageAccountName
                }
                {
                  name: 'ProcessOrderQueueName'
                  value: processOrderQueueName
                }
              ]
            }
          }
        }
        
    

### Commit and push your feature branch

Commit your changes and push them to your GitHub repository by running the following commands in the Visual Studio Code terminal:

Commit your changes and push them to your Azure Repos repository by running the following commands in the Visual Studio Code terminal:

Bash Code

    git add .
    git commit -m "Add orders queue and associated configuration"
    git push --set-upstream origin add-orders-queue
    

The feature branch is pushed to a new branch, also named _add-orders-queue_, in your remote repository.

## Try to merge the feature branch to main

You've learned why it's not advisable to push directly to the main branch. Here, you try to break that guideline so you can see how your main branch's protection prevents you from accidentally pushing your changes to a protected branch.

1.  In the Visual Studio Code terminal, run the following statements to switch to the main branch and merge the _add-orders-queue_ branch into it:
    
    Bash Code
    
        git checkout main
        git merge add-orders-queue
        
    
    The command worked, but you merged the _add-orders-queue_ branch into your main branch in only your _local_ Git repository.
    
2.  Run the following statement to try to push your changes to GitHub:
    
    Bash Code
    
        git push
        
    
    Notice that your push fails with an error message that looks like this one:
    
    plaintext Info
    
        Total 0 (delta 0), reused 0 (delta 0), pack-reused 0
        remote: error: GH006: Protected branch update failed for refs/heads/main.
        remote: error: Changes must be made through a pull request.
        To https://github.com/mygithubuser/toy-website-review.git
         ! [remote rejected] main -> main (protected branch hook declined)
        error: failed to push some refs to 'https://github.com/mygithubuser/toy-website-review.git'
        
    
    The error message tells you that pushes to the main branch aren't permitted, and that you must use a pull request to update the branch.
    
3.  Undo the merge by running the following statement:
    
    Bash Code
    
        git reset --hard HEAD~1
        
    
    This command tells your local Git repository to reset the state of the main branch to what it was before the last commit was merged in, and not to save your changes. The _add-orders-queue_ branch isn't affected.
    

You've learned why it's not advisable to push directly to the main branch. Here, you try to break that guideline so you can see how the branch policies prevent you from accidentally pushing your changes to a protected branch.

1.  In the Visual Studio Code terminal, run the following statements to switch to the main branch and merge the _add-orders-queue_ branch to it:
    
    Bash Code
    
        git checkout main
        git merge add-orders-queue
        
    
    The command worked, but you merged the _add-orders-queue_ branch into your main branch in only your local Git repository.
    
2.  Run the following statement to try to push your changes to Azure Repos:
    
    Bash Code
    
        git push
        
    
    Notice that your push fails with an error message that looks like this one:
    
    plaintext Info
    
        Total 0 (delta 0), reused 0 (delta 0), pack-reused 0
        To https://dev.azure.com/mytoycompany/toy-website-review/_git/toy-website-review
        ! [remote rejected] main -> main (TF402455: Pushes to this branch are not permitted; you must use a pull request to update this branch.)
        error: failed to push some refs to 'https://dev.azure.com/mytoycompany/toy-website-review/_git/toy-website-review'
        
    
    The error message tells you that pushes to the main branch aren't permitted, and that you must use a pull request to update the branch.
    
3.  Undo the merge by running the following statement:
    
    Bash Code
    
        git reset --hard HEAD~1
        
    
    This command tells your local Git repository to reset the state of the main branch to what it was before the last commit was merged in, and not to save your changes. The _add-orders-queue_ branch isn't affected.



# Review and merge Bicep changes

You've learned how to use feature branches and how to apply branch protection to ensure that changes are reviewed before they're merged. Now, you need to follow a consistent process to propose and review your changes before they're merged.

In this unit, you'll learn more about pull requests, including how to create and use them. You'll also learn how you can use pull requests to review Bicep code.

## Pull requests

A _pull request_ is a _request_ from you, the developer of a feature, to the maintainer of the main branch. You ask the maintainer to _pull_ your changes into the main branch of the repository.

### Pull requests and branch protections

When you configure branch protections, you can require your code owners to review the pull request. For example, you might include the project leads as reviewers for all of your pull requests, or you might specify that a certain number of people must review every pull request.

### Pull requests and branch policies

When you configure branch policies, you can require specific people or a group of people to review the pull request. For example, you might include the project leads as reviewers for all of your pull requests, or you might specify that a certain number of people must review every pull request.

You can also require that each pull request is linked to a work item. By using this configuration, you can trace from a work item that contains a feature request to the code that implements the change, all the way to deployment to your production environment.

### Create a pull request

You can create a pull request by using the GitHub web interface. You select the source branch, where you've made your changes, and the target branch, which is usually the main branch of the repository.

You can create a pull request by using the Azure DevOps web interface. You select the source branch, where you've made your changes, and the target branch, which is usually the main branch of the repository.

When you create a pull request, you need to give it a name. It's a good practice to make your pull request names clear and understandable. This practice helps your team members understand the context of what they're being asked to review. If they have different areas of expertise, a good name can help them find pull requests where they can contribute meaningful feedback and skip the pull requests that aren't relevant.

Also, pull request names often become part of your Git repository's history, so it's a good idea to make them understandable when somebody looks back at the history.

You can also give pull requests a description. You can mention specific people or refer to issues in your descriptions. Many teams create standardized templates for pull request descriptions so that it's clear what each change is.

You can also give pull requests a description. You can mention specific people or refer to work items in your descriptions. Many teams create standardized templates for pull request descriptions so that it's clear what each change is.

When you create a pull request, you can invite people to review the changes.

Sometimes, you create a pull request just to get feedback from your colleagues. In these situations, you can specify that the pull request is a _draft_. Reviewers will know that you're still working on the changes. Your reviewers can still provide feedback, but it's clear that the changes aren't ready to merge yet. When you're satisfied with your changes, you can remove the draft status.

Even after you've created a pull request, you can keep making changes to the code on your feature branch. These changes become part of the pull request.

## Review a pull request

When you review a pull request, you can see all of the changes. You can comment on the entire pull request, or just on specific parts of the files that have been changed. The pull request author can respond to comments, and other reviewers can participate in discussions. These commenting features make collaborating on pull requests an interactive experience.

When you review Bicep code, look for these key elements:

-   **Is the file deployable?** Deploy and test the Bicep code before it's merged. Ensure that there are no linter warnings, and that the Azure deployment succeeds. In a future Microsoft Learn module, you'll learn about approaches to automatically deploy and verify your changes.
-   **Is the Bicep code clear and understandable?** It's important that everybody on your team understands your Bicep code. When you review a Bicep file in a pull request, ensure that you understand exactly what every change is for. Are variables and parameters named well? Have comments been used to explain any complex sections of code?
-   **Is the change complete?** If this pull request represents part of a wider piece of work, ensure that your environment will work when this change is merged and deployed. For example, if the pull request reconfigures an Azure resource in preparation for a later change, verify that the resource continues to work correctly throughout the whole process. If the pull request adds a new Azure resource that isn't needed yet, consider whether a condition should be added temporarily so that the resource isn't deployed until it's needed.
-   **Does the change follow good Bicep practices?** In other Microsoft Learn modules, you've learned about the elements of good Bicep code. Ensure that the code you review follows those same best practices.
-   **Does the change match the description?** It's a good practice for pull requests to include a descriptive title. Many teams also require that pull requests include a description of the change and its purpose. Check that the changes to your Bicep code match the pull request details. If the pull request author has linked to work items or issues, verify that the changes in the pull request meet the success criteria that the work item has defined.

## Complete a pull request

After the pull request is approved, it can be _completed_. That means the contents of the pull request are merged into the main branch.

In some teams, the pull request author should also complete it. This process helps ensure that the author controls when the merge happens and can be available to monitor any automated deployments. In other teams, approvers complete the pull request. Your team should decide who merges pull requests and when.

In some teams, the pull request author should also complete it. This process helps ensure that the author controls when the merge happens and can be available to monitor any automated deployments. In other teams, approvers complete the pull request. You can even use Azure DevOps to automatically complete a pull request when it meets the approval criteria. Your team should decide who merges pull requests and when.

## Your team's process

After you start to use feature branches and pull requests, your team's process might change to something like the following:

1.  A team member clones your shared repository.
    
2.  They make local changes on a branch in their own local copy of the repository.
    
3.  When they're finished with their changes, they push their local branch to the shared repository.
    
4.  Within the shared repository, they create a pull request to merge the branch to _main_.
    
    Other team members review the changes. When they're satisfied, they approve the pull request and it's merged to the shared repository's main branch.
    
5.  They delete the branches in the shared repository and in their local copy of the repository.
    
    In some scenarios, the remote repository's push triggers an automated pipeline to verify, test, and deploy the code. You'll learn more about pipelines in other Microsoft Learn modules.
    

The following diagram illustrates this revised process.

![Diagram that shows the process of making local changes, opening a pull request, deleting the local branch, and triggering a pipeline.](https://learn.microsoft.com/en-us/training/modules/review-azure-infrastructure-changes-using-bicep-pull-requests/media/4-revised-process.png)



# Exercise - Create, review, and merge a pull request

You've completed the work to add a queue to your website. Now, the website development team is ready for you to merge the changes to your main branch. In this exercise, you'll create and merge a pull request for your changes.

During the process, you'll:

-   Create a pull request.
-   Review the pull request.
-   Complete the pull request.
-   Verify that the changes have been merged.

## Create a pull request to merge the feature branch

Because you can't push changes directly to your repository's main branch, you need to create a pull request.

1.  In your browser, go to **Code**.
    
2.  Select **2 branches** to list the branches in your GitHub repository.
    
    ![Screenshot of GitHub that shows the repository page with the link to the branch list highlighted.](https://learn.microsoft.com/en-us/training/modules/review-azure-infrastructure-changes-using-bicep-pull-requests/media/5-github-branches.png)
    
3.  Next to **add-orders-queue**, select the **More** icon (**...**), then select **New pull request**.
    
    ![Screenshot of GitHub that shows the branch list. The button for a new pull request is highlighted for the add-orders-queue branch.](https://learn.microsoft.com/en-us/training/modules/review-azure-infrastructure-changes-using-bicep-pull-requests/media/5-github-new-pull-request.png)
    
4.  When you created the pull request, notice that GitHub automatically used the Git commit message as the pull request's title.
    
    Update the description to the following text:
    
    _This PR adds a new Azure Storage queue for processing orders, and updates the website configuration to include the storage account and queue information._
    
5.  Select **Create pull request**.
    
    ![Screenshot of GitHub that shows the pull request creation page, with the button for creating a pull request highlighted.](https://learn.microsoft.com/en-us/training/modules/review-azure-infrastructure-changes-using-bicep-pull-requests/media/5-github-pull-request-create.png)
    

1.  In your browser, go to **Repos** > **Files**.
    
    Notice that Azure DevOps shows a banner that indicates there are changes in the _add-orders-queue_ branch. The banner offers to create a pull request for those changes.
    
    ![Screenshot of Azure DevOps that shows the repository's file list, including a banner that offers to create a pull request.](https://learn.microsoft.com/en-us/training/modules/review-azure-infrastructure-changes-using-bicep-pull-requests/media/5-repos-new-pull-request.png)
    
2.  Select **Create a pull request**.
    
3.  On the page for creating a pull request, notice that Azure DevOps automatically used the Git commit message as the pull request title.
    
    Update the description to the following text:
    
    _This PR adds a new Azure Storage queue for processing orders, and updates the website configuration to include the storage account and queue information._
    
4.  Select **Create**.
    
    ![Screenshot of Azure DevOps that shows the pull request creation page, with the button for creating a pull request highlighted.](https://learn.microsoft.com/en-us/training/modules/review-azure-infrastructure-changes-using-bicep-pull-requests/media/5-repos-pull-request-create.png)
    

## Review the pull request

Normally, a pull request is reviewed by someone other than its author. For this example, you'll pretend to be another team member and review your own pull request.

1.  From the pull request page, select the **Files changed** tab.
    
    ![Screenshot of GitHub that shows the tab for changed files in a pull request.](https://learn.microsoft.com/en-us/training/modules/review-azure-infrastructure-changes-using-bicep-pull-requests/media/5-github-pull-request-review-files-changed.png)
    
    GitHub shows you the files that were changed in this pull request. Notice that it highlights all of the lines that have changed, so you can easily see what you should review.
    
    >Tip
    >
    >Imagine that you're reviewing this for your own team. Would you make any suggestions?
    
2.  In the _main.bicep_ file that was changed, hover over line 18 and select the button with the **plus sign** (**+**).
    
    ![Screenshot of GitHub that shows changes to the main dot bicep file. The mouse is hovering over line 18, and the button for adding comments is highlighted.](https://learn.microsoft.com/en-us/training/modules/review-azure-infrastructure-changes-using-bicep-pull-requests/media/5-github-pull-request-review-line.png)
    
3.  In the comment box, enter the following text: _Should this be capitalized?_
    
4.  Select **Start a review**.
    
    ![Screenshot of GitHub that shows the comment field, with the button for starting a review highlighted.](https://learn.microsoft.com/en-us/training/modules/review-azure-infrastructure-changes-using-bicep-pull-requests/media/5-github-pull-request-review-comment.png)
    
    >Tip
    >
    >GitHub doesn't let you approve your own pull requests. Here, you'll comment on your pull request, but won't approve it. When you work with your own team's pull requests, this is the point at which you'd approve it to indicate you're happy for it to be merged.
    
5.  Select **Finish your review**.
    
6.  In the review panel that appears, select **Submit review**.
    
    ![Screenshot of GitHub that shows the panel for finishing a review, with the button for submitting a review highlighted.](https://learn.microsoft.com/en-us/training/modules/review-azure-infrastructure-changes-using-bicep-pull-requests/media/5-github-pull-request-review-submit.png)
    
    GitHub returns you to the pull request's **Conversation** tab.
    

1.  From the pull request page, select the **Files** tab.
    
    ![Screenshot of Azure DevOps that shows the files changed in the pull request.](https://learn.microsoft.com/en-us/training/modules/review-azure-infrastructure-changes-using-bicep-pull-requests/media/5-repos-pull-request-review-files-changed.png)
    
    Azure DevOps shows you the files that were changed in this pull request. Notice that it highlights all of the lines that have changed, so you can easily see what you should review.
    
    Tip
    
    Imagine that you're reviewing this for your own team. Would you make any suggestions?
    
2.  In the _main.bicep_ file that was changed, hover over line 18 and select the comment button.
    
    ![Screenshot of Azure DevOps that shows changes to the main dot bicep file. The mouse is hovering over line 18, and the button for adding a comment is highlighted.](https://learn.microsoft.com/en-us/training/modules/review-azure-infrastructure-changes-using-bicep-pull-requests/media/5-repos-pull-request-review-line.png)
    
3.  In the comment box, enter the following text: _Should this be capitalized?_
    
4.  Select **Comment**.
    
    ![Screenshot of Azure DevOps that shows the comment field, with the Comment button highlighted.](https://learn.microsoft.com/en-us/training/modules/review-azure-infrastructure-changes-using-bicep-pull-requests/media/5-repos-pull-request-review-comment.png)
    
    The width of your browser window can affect how the comment dialog box is displayed. The comment will open a **Discussion** dialog box rather than the inline comment as shown in the screenshot.
    
5.  Select **Approve**.
    
    ![Screenshot of Azure DevOps that shows the Approve button for the pull request.](https://learn.microsoft.com/en-us/training/modules/review-azure-infrastructure-changes-using-bicep-pull-requests/media/5-repos-pull-request-approve.png)
    
    After you select **Approve**, the **Set auto-complete** changes to **Complete**. You'll use that feature later in this unit.
    

## Respond to the pull request review

When you create or review a pull request, you can participate in a conversation about its contents. Imagine that you're the author of this file and you want to respond to a comment from the reviewer.

1.  Respond to the review of the pull request with the following comment: _No, storage queues must have lowercase names._
    
2.  Select **Comment**, and then select **Resolve conversation** to indicate that the discussion on the line is over.
    
    ![Screenshot of GitHub that shows the response to a comment, with the buttons for entering a comment and resolving a conversation highlighted.](https://learn.microsoft.com/en-us/training/modules/review-azure-infrastructure-changes-using-bicep-pull-requests/media/5-github-pull-request-respond-comment.png)
    

1.  From the pull request page, select the **Overview** tab.
    
    ![Screenshot of Azure DevOps that shows the Overview tab.](https://learn.microsoft.com/en-us/training/modules/review-azure-infrastructure-changes-using-bicep-pull-requests/media/5-repos-pull-request-overview.png)
    
2.  Now, imagine that you're the author of this file. Respond to the review of the pull request with the following comment: _No, storage queues must have lowercase names._
    
3.  Select **Reply & resolve** to indicate that the discussion on the line is over.
    
    ![Screenshot of Azure DevOps that shows the response to a comment, with the button for replying and resolving highlighted.](https://learn.microsoft.com/en-us/training/modules/review-azure-infrastructure-changes-using-bicep-pull-requests/media/5-repos-pull-request-respond-comment.png)
    

## Complete the pull request

Your website's development team has confirmed it's ready for you to send the orders to the queue, so you're ready to complete and merge your pull request.

Your pull request has been approved. Your website's development team has confirmed it's ready for you to send the orders to the queue, so you're ready to complete and merge your pull request.

1.  Select **Merge pull request**.
    
    ![Screenshot of GitHub that shows a pull request with the button for merging highlighted.](https://learn.microsoft.com/en-us/training/modules/review-azure-infrastructure-changes-using-bicep-pull-requests/media/5-github-pull-request-merge.png)
    
2.  GitHub asks you to confirm the merge. When GitHub merges the pull request, it creates a commit and automatically generates a commit message. Select **Confirm merge**.
    
    ![Screenshot of GitHub that shows a pull request with the button for confirming a merge highlighted.](https://learn.microsoft.com/en-us/training/modules/review-azure-infrastructure-changes-using-bicep-pull-requests/media/5-github-pull-request-merge-confirm.png)
    
    Your pull request is merged, and your new feature is now in the main branch of your repository.
    
3.  It's a good practice to delete your feature branches when you're done with them. Deleting branches helps you avoid confusing team members in the future about which work is still in progress. Select **Delete branch**.
    
    ![Screenshot of GitHub that shows a pull request with the button for deleting a branch highlighted.](https://learn.microsoft.com/en-us/training/modules/review-azure-infrastructure-changes-using-bicep-pull-requests/media/5-github-pull-request-merge-delete.png)
    

1.  Select **Complete**.
    
    ![Screenshot of Azure DevOps that shows the Complete button for a pull request.](https://learn.microsoft.com/en-us/training/modules/review-azure-infrastructure-changes-using-bicep-pull-requests/media/5-repos-pull-request-complete.png)
    
2.  From **Complete pull request**, use the default settings. Select **Complete merge**.
    
    ![Screenshot of Azure DevOps that shows the pull request completion panel, with the button for completing a merge highlighted.](https://learn.microsoft.com/en-us/training/modules/review-azure-infrastructure-changes-using-bicep-pull-requests/media/5-repos-pull-request-complete-merge.png)
    
    Your pull request is merged, and your new feature is now in the main branch of your repository.
    
    Azure DevOps automatically deleted the feature branch when you merged the pull request. It's a good practice to delete your feature branches when you're done with them. Deleting branches helps you avoid confusing team members in the future about which work is still in progress.
    

## Verify the changes

After you merge a pull request, it's a good idea to confirm that the changes were merged successfully.

1.  Go to **Code**.
    
2.  Go to the _deploy/main.bicep_ file, and then to the _deploy/modules/appService.bicep_ file.
    
    ![Screenshot of GitHub that shows the repository's file list after the pull request is merged.](https://learn.microsoft.com/en-us/training/modules/review-azure-infrastructure-changes-using-bicep-pull-requests/media/5-github-code-final.png)
    
    Notice that the queue and your other changes are now in the files.



# Module assessment

You configure branch protection for your repository's main branch. You use the following settings:

![Screenshot of GitHub branch protection rules. The option for requiring approvals is enabled, and the number of approvals required before merging is 2.](https://learn.microsoft.com/en-us/training/modules/review-azure-infrastructure-changes-using-bicep-pull-requests/media/6-branch-protection-github.png)

You configure branch policies for your repository's main branch. You use the following settings:

![Screenshot of Azure DevOps branch policies. The minimum number of required reviewers is set to 2.](https://learn.microsoft.com/en-us/training/modules/review-azure-infrastructure-changes-using-bicep-pull-requests/media/6-branch-protection-azure-repos.png)

1. 

Which of these statements is true?

- Anybody on the team can push a change directly to the main branch.

- The manager of the team must review all pull requests.

- -> The pull request's author can push a change to the pull request's source branch.

2. 

You want to get your colleagues' input on a change you're making to a Bicep file, but you aren't finished with the change yet. What should you do?

- Create a pull request, and configure branch protection rules to prohibit the branch from being merged.

- -> Create a pull request and mark it as a draft.

- Email your colleagues a link to your branch.

3. 

You're reviewing a pull request from a colleague. You notice that the Bicep file has a typo in a variable name. The typo will cause an error when the template is deployed. What should you do?

- -> Add a comment to the pull request's author to let them know.

- Reject the pull request.

- Approve the pull request. The author will notice the problem when they deploy the Bicep file.



# Summary

Your team wanted a way to protect the Bicep code on your main branch and prevent accidental changes that might affect your production Azure resources. You wanted to review any Bicep code before it's merged into your main branch.

In this module, you learned how to use feature branches to separate your team's in-progress work from the Bicep code that you use for your real Azure environments. You also learned how to use pull requests so that your team can review your Bicep code changes before they're merged and deployed.

You've now increased your team's confidence in your Bicep development process and reduced the chances of anyone deploying faulty Bicep code to your production environment.

## References

-   Branching
    -   [Merge strategies and squash merge](https://learn.microsoft.com/en-us/azure/devops/repos/git/merging-with-squash)
    -   [Trunk-based development](https://trunkbaseddevelopment.com/)
    -   [Gitflow](https://nvie.com/posts/a-successful-git-branching-model/)
    -   [GitHub flow](https://docs.github.com/get-started/quickstart/github-flow)
    -   [Patterns for Managing Source Code Branches](https://martinfowler.com/articles/branching-patterns.html)
-   Pull requests on Microsoft Learn
    -   [Manage repository changes by using pull requests on GitHub](https://learn.microsoft.com/en-us/training/modules/manage-changes-pull-requests-github/)
    -   [Collaborate with pull requests in Azure Repos](https://learn.microsoft.com/en-us/training/modules/collaborate-pull-requests-azure-repos/)
-   Bicep best practices
    -   [Structure your Bicep code for collaboration](https://learn.microsoft.com/en-us/training/modules/structure-bicep-code-collaboration/)
    -   [Best practices for Bicep](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/best-practices)



