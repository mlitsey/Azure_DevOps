# Manage changes to your Bicep code by using Git

# Introduction

As your use of Bicep and infrastructure as code matures, it becomes increasingly important to have a systematic process to manage your files. It's easy to lose track of the changes you make, especially if you have multiple versions of a file in development at the same time.

You also need to consider how you share your templates with your colleagues, and ensure you have a process to track and communicate your changes. Additionally, when you work with pipelines to deploy your Bicep code, it's essential to keep your templates in a version control system so that the pipeline can access them.

In this module, you'll learn about the popular version control system called Git.

## Example scenario

Suppose you're responsible for deploying and configuring the Azure infrastructure at a toy company. You've created Bicep templates and stored them on your own computer.

You're building such a large collection of templates that you're finding it hard to keep track of things. You've experimented with changes to some of your templates and have multiple copies of files. You even accidentally broke a working template by making a change to it before you went on vacation, and now you can't remember what you changed or how to fix it.

You feel like there must be a better way to manage your Bicep code. You want to start by improving the way you work with the Bicep files that deploy your company's website.

## What will we be doing?

In this module, you'll create a Git repository and add some of your Bicep files to it. You'll explore some important Git features and see how they can help as you write your Bicep code. You'll also learn about GitHub and Azure Repos, and how publishing your Git repository to one of these services enables you to collaborate with your team.

## What is the main goal?

By the end of this module, you'll have an understanding of what version control and Git can do to help you as you work with Bicep code. You'll be able to use the Visual Studio Code support for Git to initialize a local Git repository, commit files, create branches, and merge branches. Finally, you'll be able to publish a Git repository to GitHub or Azure Repos.

## Prerequisites

You should be familiar with creating basic Bicep templates, including modules.

To follow along with the exercises in the module, you'll need [Visual Studio Code](https://code.visualstudio.com/) installed locally.

# Understand Git

Version control tools like Git give you the ability to track and manage changes to your files as you work. You can store multiple versions of the same file, view the history of the changes you've made, and collaborate with others.

Git is one of the most popular version control tools. In this unit, you'll learn about Git and how it can help when you're writing and working with Bicep code.

## What are version control and Git?

Version control is a practice by which you maintain a history of changes to your files. Many different version control systems exist, but generally they have some core features:

-   Track the changes you make to a file.
-   View the history of a file, and go back to an older version if you need to revert a change you've made.
-   Work with multiple versions of a file at the same time.
-   Collaborate with other team members by sharing your code and changes.

Most version control systems work with all file types, but they're optimized for text files.

> 📝 **Note**
>
>Version control is also sometimes called source code management, or SCM.

Git is an open-source version control system. By using Git, you create _repositories_ that maintain history and track changes. You can use different repositories for each project, or you might choose to use a single repository for all your Bicep code.

## How does Git help with your Bicep code?

Bicep code is maintained in text files, so it's a good fit for many version control systems. Version control helps with common scenarios that you likely face as you write your Bicep code, such as:

-   When you make changes to your Bicep files, you often need to undo a change or view the history of a file to see the changes you've made in the past. You could make copies of each file as you change them, but this quickly gets difficult to manage. Git provides features to keep track of your changes to each file.
-   You need to make a major change to a Bicep file, which takes some time to prepare and test. At the same time, you need to access the current _known good_ version of the Bicep file so you can continue to deploy it. Git provides features for _branching_ and _merging_ so you can work with multiple versions of a file and quickly switch between them.
-   You work with other people on your team who make changes to your Bicep code. You need to track who makes each change. If two changes conflict with each other, you need to have a process to resolve the conflicts. Git provides powerful collaboration features.

## Where is each repository?

Git is a _distributed_ version control system, which means you can have multiple copies of your Git repository across computers and servers. This makes Git an excellent choice for collaborating with team members to share and write your Bicep code together.

You use online services like GitHub and Azure Repos to work with your team on shared code. By using these services, you can also start to build automated deployment pipelines. You'll learn about those pipelines in a future module.

## How does Git work with folders?

A Git repository is represented as a folder on your computer. When you work with the repository, it's just like working with any other folder with files in it. You can view and edit the files by using any tools you want, although in this module you'll use Visual Studio Code.

Git stores some metadata about the repository in a special hidden folder within your repository's folder. When you first create a repository, you need to _initialize_ the repository to create the metadata. After that, you work with the folder as normal. Git's tools help you maintain the versions of the files in the repository. You'll learn more about Git's commands throughout this module.

## What tools will I need?

In this module, you'll use two tools to work with your Git repository: Visual Studio Code and Git.

### Visual Studio Code

Visual Studio Code is a text editor for Windows, macOS, and Linux. It provides features to work with Bicep code, along with other source code and text files. For example, by installing the [Bicep extension for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep), you get an editing experience for Bicep that includes autocomplete, IntelliSense, and suggestions for how your code can be improved.

You can write Bicep code by using another text editor if you want, but Visual Studio Code is a great choice because it has Bicep support and it integrates with Git.

### Git

Git is based on a command-line tool, and most of the documentation and examples you'll find online use the Git command-line interface (CLI). In this module, we'll use a mixture of CLI commands and Visual Studio Code to work with Git. Whichever tool you use, you work with the same underlying Git repository.

> 💡 **Tip**
>
>As your use of Git matures, you'll need to learn some more advanced Git CLI commands. Later in this module, we link to some resources to continue your exploration of Git and its many advanced features.

You need to install Git separately from Visual Studio Code. You'll see how to do this in the next unit. After you install Git, Visual Studio Code detects it and enables its Git integration automatically.

# Exercise - Initialize a Git repository

You've decided that your workflow could benefit from a version control system, and you're going to try Git. In this exercise, you'll get everything ready so that you can start to work with Git.

During the process, you'll:

-   Install and configure Git.
-   Create and initialize a Git repository.
-   Add a Bicep file to the repository folder and see how the repository's status changes.

> 📝 **Note**
>
>Visual Studio Code is a powerful editor, and it has many different ways of achieving the same thing. Almost every action has keyboard shortcuts. There are often several ways to perform common actions by using the user interface too. This module will guide you to perform the actions by using one approach. Feel free to use a different approach if you want.

## Install Git

1.  [Install Git](https://git-scm.com/download). Choose the correct version based on your operating system.
    
2.  If you already have Visual Studio Code open, restart it so that it detects your Git installation.
    

## Configure Git

You need to run a few commands to configure Git so that it associates your name and email address with your activity. This identification helps when you use Git to collaborate with others. If you've already configured Git, you can skip these steps and move to the next section.

1.  Open Visual Studio Code.
    
2.  Open a Visual Studio Code terminal window by selecting **Terminal** > **New Terminal**. The window usually opens at the bottom of the screen.
    
3.  Verify that Git is installed by entering the following command:
    
    Bash Code
    
        git --version
        
    
    If you see an error, [make sure you've installed Git](https://git-scm.com/download), restart Visual Studio Code, and try again.
    
4.  Set your name by using the following command. Replace `USER_NAME` with the username that you want to use. Use your first name and last name so that your team members know it's you.
    
    Bash Code
    
        git config --global user.name "USER_NAME"
        
    
5.  Set your email address by using the following command. Replace `USER_EMAIL_ADDRESS` with your email address.
    
    Bash Code
    
        git config --global user.email "USER_EMAIL_ADDRESS"
        
    
6.  Run the following command to check that your changes worked:
    
    Bash Code
    
        git config --list
        
    
7.  Confirm that the output includes two lines that are similar to the following example. Your name and email address will be different from what's shown in the example.
    
    Output Copy
    
        user.name=User Name
        user.email=user-name@contoso.com
        
    

## Create and initialize a Git repository

1.  In the Visual Studio Code terminal, create a new folder named _toy-website_:
    
    Bash Code
    
        mkdir toy-website
        cd toy-website
        
    
2.  By using the Visual Studio Code terminal, run the following command to reopen Visual Studio Code with the _toy-website_ folder loaded:
    
    Bash Code
    
        code --reuse-window .
        
    
    Visual Studio Code reloads. If you're prompted to trust the folder, select **Yes, I trust the authors**.
    
3.  In the Visual Studio Code terminal, run the following command to initialize a new Git repository in the _toy-website_ folder that you created:
    
    Bash Code
    
        git init
        
    
    Git displays a message confirming that it initialized an empty Git repository.
    

## Add a Bicep file

1.  Create a subfolder named _deploy_. You can create the folder using **Explorer** in Visual Studio Code, or you can use the following command in the Visual Studio Code terminal:
    
    Bash Code
    
        mkdir deploy
        
    
2.  In the _deploy_ folder, create a new file called _main.bicep_.
    
3.  Open and save the empty file so that Visual Studio Code loads the Bicep tooling.
    
    You can either select **File** > **Save As** or select the keyboard shortcut Ctrl+S for Windows (⌘+S for macOS). Be sure to remember where you save the file. For example, you might want to create a _scripts_ folder to save it in.
    
4.  Copy the following code into _main.bicep_.
    
    Bicep Code
    
        @description('The Azure region into which the resources should be deployed.')
        param location string = resourceGroup().location
        
        @description('The type of environment. This must be nonprod or prod.')
        @allowed([
          'nonprod'
          'prod'
        ])
        param environmentType string
        
    
    This Bicep file contains two parameters but doesn't define any resources yet.
    
5.  Save the file.
    

> 📝 **Note**
>
>Even though you've saved the file into your repository's folder, Git isn't _tracking_ it yet. You'll learn how Git keeps track of files in the next unit.

## Inspect the repository status by using the CLI

Git monitors the repository folder for changes. You can query Git to see the list of files that have been modified. This feature is useful to see what you've done and to verify you haven't accidentally added files or made changes that you didn't mean to include. You can use both the Git CLI and Visual Studio Code to view the status of your repository.

1.  By using the Visual Studio Code terminal, run the following command:
    
    Bash Code
    
        git status
        
    
2.  Look at the results. They're similar to the following example:
    
    Output Copy
    
        On branch main
        
        No commits yet
        
        Untracked files:
          (use "git add <file>..." to include in what will be committed)
                deploy/
        
        nothing added to commit but untracked files present (use "git add" to track)
        
    
    This text tells you four pieces of information:
    
    -   You're currently on the _main_ branch. You'll learn about branches shortly.
    -   There have been no commits to this repository. You'll learn about commits in the next unit.
    -   There are untracked files in the _deploy_ folder.
    -   You haven't told Git to add any files to be tracked by the repository yet.
3.  Look at the first line of the output from the preceding step. If it shows a branch name that's different from _main_, run the following command to rename your branch to _main_:
    
    Bash Code
    
        git branch -M main
        
    
    This command ensures you can follow along with the remaining exercises in this module.
    

## Inspect the repository status by using Visual Studio Code

Visual Studio Code shows the same information that the `git status` command provides, but it integrates the information into the Visual Studio Code interface.

1.  In Visual Studio Code, select **View** > **Source Control**, or select Ctrl+Shift+G on the keyboard.
    
    **Source Control** opens.
    
    ![Screenshot of Visual Studio Code that shows Source Control, with one change on the icon badge and the main.bicep file listed as a changed file.](https://learn.microsoft.com/en-us/training/modules/manage-changes-bicep-code-git/media/3-vscode-source-control.png)
    
    Visual Studio Code shows that the _main.bicep_ file in the _deploy_ folder has changed. Additionally, the **Source Control** icon has a badge that shows the number **1**, which indicates one untracked file.
    
2.  The status bar appears at the bottom of Visual Studio Code. It provides useful information and functionality. Toward the left side, the status bar shows the word _main_:
    
    ![Screenshot of the Visual Studio Code status bar that shows the branch name as main.](https://learn.microsoft.com/en-us/training/modules/manage-changes-bicep-code-git/media/3-vscode-status-bar.png)
    
    This word indicates that you're currently on the _main_ branch. You'll learn about branches shortly.
    

The status reported by Git and Visual Studio Code is the same because the Git CLI and Visual Studio Code use the same Git engine. You can mix and match the tools that you use to work with your repositories. You can use different tools based on what suits you best.


# Commit files and view history

Now that you've initialized your Git repository, you're ready to start adding files. In this unit, you'll learn how to tell Git to track the changes to files in your repository.

> 📝 **Note**
>
>The commands in this unit are shown to illustrate concepts. Don't run the commands yet. You'll practice what you learn here soon.

## Folder structure for your repository

When you work with a version control system like Git, it's important to plan how you store your files. It's a good idea to have a clear folder structure.

If you're building Bicep code to deploy an application or another solution, it's also a good idea to store your Bicep files in the same repository as the application code and other files. That way, anytime someone needs to add a new feature that changes both Bicep and application code, they'll be tracked together.

Planning your folder structure also makes it easier to deploy your solution from a pipeline. You'll learn about pipelines in a future module.

Different teams have different conventions for how they set up their repository folders and files. Even if you aren't working with a team, it's still a good idea to decide on a convention to follow. A good file and folder structure will help anyone who has to work with your code in future.

If your team doesn't already have a preference, here's a suggestion for how you might do it:

-   At the root of your repository, create a _README.md_ file. This text file, written in Markdown, describes the repository's contents and gives instructions to help team members work in the repository.
-   At the root of your repository, create a _deploy_ folder. Inside the folder:
    -   Store your main Bicep template, named _main.bicep_.
    -   Create a _modules_ subfolder, to store your Bicep modules.
    -   If you have other scripts or files that are used during deployments, store them in the _deploy_ folder.
-   At the root of your repository, create a _src_ folder for source code. Use it to store application code.
-   At the root of your repository, create a _docs_ folder. Use it to store documentation about your solution.

Here's an illustration of how this structure might look for your toy company's website:

![Diagram that illustrates a folder hierarchy.](https://learn.microsoft.com/en-us/training/modules/manage-changes-bicep-code-git/media/4-folder-structure.png)

## Stage your changes

After you make changes to a file or files, you need to _stage_ them. Staging tells Git that you consider the changes important enough to keep. It might seem like an unnecessary step, but staging gives you flexibility as you work. For example, you might make changes to several files but want to keep only one of them. Or, you might want to keep only some of the changes that you've made to a file.

To stage a file, you use the `git add` command and specify the file name or folder name that you want to stage. After you stage a file, Git knows that you might want to commit the changes. When you query the repository status by using `git status`, you see the staged changes.

> ⚠️ **Important**
>
>After you stage a file, if you make any further changes to it before you commit, Git won't record those changes. You need to stage the file again for Git to include the most recent changes.

For example, imagine you've created a Bicep module to define an Azure Cosmos DB account. It's named _cosmos-db.bicep_, and you saved it in the _deploy/modules_ folder. Here's how you could stage the file:

Bash Code

    git add deploy/modules/cosmos-db.bicep
    

You can also stage all of the changes in your repo by running this command from the root folder of your repository:

Bash Code

    git add .
    

## Commit the staged changes

A _commit_ represents a set of changes to one or more files in your repository. When you're ready to commit the changes you've staged, you use the `git commit` command. Your commit includes a _commit message_, which is a human-readable description of the changes.

Here's an example that shows how you commit the staged changes shown earlier:

Bash Code

    git commit --message "Add Cosmos DB account definition"
    

> 📝 **Note**
>
>Visual Studio Code can commit to your Git repository too. When you use Git integration in Visual Studio Code, if you haven't already staged the files, Visual Studio Code asks if you want it to stage all of the changed files for you. You can even set this as the default behavior. Or, if you prefer, you can manually stage and unstage files by using **Source Control** in Visual Studio Code.

Make your commit messages short, but make them descriptive. When you or a team member reviews the commit history in the future, each commit message should explain what the change was and why you made it.

There aren't any rules about what commit messages need to contain or how they're formatted. But conventionally, they're written in the present tense and in a full sentence, as if you're giving orders to your codebase.

> 💡 **Tip**
>
>It's a good practice to write descriptive commit messages even when you're working on your own. Someone else might need to look at your code in the future. Even if they don't, you might need to review your own history, and you want to make your own life easier!

Here are some examples of good commit messages:

-   _Update App Service configuration to add network configuration._
-   _Remove storage account since it's been replaced by a Cosmos DB database._
-   _Add Application Insights resource definition and integrate with function app._

## View a file's history

After you commit files to your Git repository, you can use the `git log` CLI command to view the history of a file or even all the commits to the repository.

To view a list of commits, run the following command:

Bash Code

    git log --pretty=oneline
    

The output of this command shows a list of the commits, with the most recent commits first. Each line includes the _commit hash_, which is an identifier that Git internally uses to track each commit. It also includes the commit message, which is one of the reasons why it's so important to write good commit messages.

It's also common to view the commits to a specific file. You can specify the file name when you run the `git log` command, like this:

Bash Code

    git log deploy/main.bicep
    

The Git CLI and the `git log` command provide many arguments that you can use to view information about your commits and files. However, it's often easier to use Visual Studio Code to view the commit history for a file.

In the Visual Studio Code **Explorer** pane, you can select and hold (or right-click) a file in your repository and then select **View Timeline**. The **Timeline** pane opens and shows a list of each commit that affected that file. When you select a commit, you see the exact changes to the file. You'll see how to use this information in the next exercise.


# Exercise - Commit files to your repository and view their history

In the previous exercise, you initialized a Git repository for your toy company's website. You added a Bicep file, but you didn't commit it.

In this exercise, you'll:

-   Commit the file that you created in the previous exercise.
-   Add a new Bicep module, and compare the differences in your Bicep code by using Git.
-   Commit the updated Bicep code.
-   View the commit history and the main Bicep file's history.

The process of making more changes to your Bicep code will show you how Git and Visual Studio Code help you track and manage changes.

## Commit the Bicep file by using the Git CLI

1.  By using the Visual Studio Code terminal, run the following command to stage the _main.bicep_ file:
    
    Bash Code
    
        git add deploy/main.bicep
        
    
2.  Run the following command to commit the staged changes and provide a commit message:
    
    Bash Code
    
        git commit --message "Add first version of Bicep template"
        
    

## Add a Bicep module

Here you add a Bicep module and reference it from your _main.bicep_ file.

1.  In the _deploy_ folder, create a subfolder named _modules_.
    
2.  In the _modules_ folder, create a new file named _app-service.bicep_.
    
3.  Open and save the empty _app-service.bicep_ file so that Visual Studio Code loads the Bicep tooling.
    
4.  Copy the following code into _app-service.bicep_:
    
    Bicep Copy
    
        @description('The Azure region into which the resources should be deployed.')
        param location string
        
        @description('The type of environment. This must be nonprod or prod.')
        @allowed([
          'nonprod'
          'prod'
        ])
        param environmentType string
        
        @description('The name of the App Service app. This name must be globally unique.')
        param appServiceAppName string
        
        var appServicePlanName = 'toy-website-plan'
        var appServicePlanSkuName = (environmentType == 'prod') ? 'P2v3' : 'F1'
        var appServicePlanTierName = (environmentType == 'prod') ? 'PremiumV3' : 'Free'
        
        resource appServicePlan 'Microsoft.Web/serverfarms@2024-04-01' = {
          name: appServicePlanName
          location: location
          sku: {
            name: appServicePlanSkuName
            tier: appServicePlanTierName
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
        
    
5.  Save and close the _app-service.bicep_ file.
    
6.  Open the _main.bicep_ file.
    
7.  Under the parameter declarations, add the following parameter declaration and module definition:
    
    Bicep Copy
    
        @description('The name of the App Service app. This name must be globally unique.')
        param appServiceAppName string = 'toyweb-${uniqueString(resourceGroup().id)}'
        
        module appService 'modules/app-service.bicep' = {
          name: 'app-service'
          params: {
            location: location
            environmentType: environmentType
            appServiceAppName: appServiceAppName
          }
        }
        
    
8.  Save and close the _main.bicep_ file.
    

## Compare the differences

Now that you've made a change to the _main.bicep_ file, let's inspect the differences. It's a good idea to review the differences in each file you're about to stage and commit. You do the review to verify that your changes are correct.

1.  In Visual Studio Code, select **View** > **Source Control**, or select Ctrl+Shift+G on the keyboard.
    
2.  On the **Source Control** panel that opens, select the _main.bicep_ file.
    
    A view of file differences opens.
    
    ![Screenshot of Visual Studio Code that shows the differences between the current main.bicep file and the modified version.](https://learn.microsoft.com/en-us/training/modules/manage-changes-bicep-code-git/media/5-vscode-diff.png)
    
    Notice that Visual Studio Code shows you the changes you've made. The original file is on the left, and the changed file is on the right. Additions to the file are displayed in green. When you edit a file and remove content, the deletions are displayed in red.
    
3.  Open the differences for the _app-service.bicep_ file.
    
    Notice that there's nothing on the left side of the difference view, because this file is new and wasn't already added to the repository.
    

## Commit the updated Bicep code by using Visual Studio Code

Now that you've reviewed the changes and are satisfied with it, you commit the update to the file. This time, you use Visual Studio Code.

1.  Open **Source Control**.
    
    Two changed files should appear. If you don't see them, select the refresh button so that Visual Studio Code scans for changes.
    
    ![Screenshot of Visual Studio Code that shows Source Control, with the Refresh toolbar icon highlighted.](https://learn.microsoft.com/en-us/training/modules/manage-changes-bicep-code-git/media/5-vscode-refresh.png)
    
2.  Select each of the two changed files and stage them. You can select the plus (**+**) icon on each file, or you can select and hold (or right-click) each file and select **Stage Changes**.
    
    ![Screenshot of Visual Studio Code that shows Source Control, with the main.bicep context menu displayed and the Stage Changes menu item highlighted.](https://learn.microsoft.com/en-us/training/modules/manage-changes-bicep-code-git/media/5-vscode-stage.png)
    
3.  At the top of **Source Control**, enter a descriptive commit message, like:
    
    plaintext Copy
    
        Add App Service module
        
    
4.  Select the check-mark icon above the text box for the commit message. Or you can select **Commit**.
    
    ![Screenshot of Visual Studio Code that shows Source Control, with the commit icon highlighted.](https://learn.microsoft.com/en-us/training/modules/manage-changes-bicep-code-git/media/5-vscode-commit.png)
    
    Visual Studio Code commits the two changes.
    

## View the commit history by using the Git CLI

1.  In the Visual Studio Code terminal, enter the following command to view the repository's commit history:
    
    Bash Code
    
        git log --pretty=oneline
        
    
    The output looks similar to the following example:
    
    Output Copy
    
        238b0867f533e14bcaabbade31b9d9e1bda6123b (HEAD -> main) Add App Service module
        9e41f816bf0f5c590cee88590aacc977f1361124 Add first version of Bicep template
        
    
2.  Inspect the output. Notice that both of your commits appear in the commit history.
    

## View a file's history by using Visual Studio Code

You can also view the history of a single file, the state of the file from that commit, and the change that the commit applied.

1.  Open **Explorer** in Visual Studio Code.
    
2.  Select and hold (or right-click) the _main.bicep_ file, and then select **Open Timeline**.
    
    ![Screenshot of Visual Studio Code that shows the Explorer panel, with the shortcut menu displayed for the main.bicep file and the Timeline menu item highlighted.](https://learn.microsoft.com/en-us/training/modules/manage-changes-bicep-code-git/media/5-vscode-timeline-menu.png)
    
    The timeline opens and shows both commits.
    
    ![Screenshot of Visual Studio Code that shows the timeline for the main.bicep file, with two commits listed.](https://learn.microsoft.com/en-us/training/modules/manage-changes-bicep-code-git/media/5-vscode-timeline.png)
    
3.  Select each commit in the list to view the state of the file at that point in time.


# Branch and merge your changes

When you work on Bicep code, it's common to need to do more than one thing at a time. For example, here are two scenarios for working with your toy company's website:

-   Your website's development team wants your help in updating Bicep files with significant changes. However, the team doesn't want those changes to go live yet. You need to be able to make minor tweaks to the current live version of the website in parallel with the work on the new version.
-   You're working on experimental changes that you think will help to improve the performance of the website. However, these changes are preliminary. You don't want to apply them to the live version of the website until you're ready.

In this unit, you learn about Git branches.

Note

The commands in this unit are shown to illustrate concepts. Don't run the commands yet. You'll practice what you learn here soon.

## What are branches?

A _branch_ provides a way to have multiple active copies of your files. You can create and switch between branches whenever you want. When you're done working with a branch, you can _merge_ it into another branch. Or you can delete it, which removes all of the changes.

It's common to use branches for all of your work. Often, you designate one branch as the primary branch that represents the _known good_ or live version of your files. By convention, this branch is usually called _main_. You can create any number of other branches. When your changes on a branch are ready, you merge the branch into the _main_ branch.

## Create and check out a branch

Creating a branch is quick and easy in Git. There are a few ways to do it, but the easiest way is typically to use the `git checkout` command. Here's an example of how we create a new branch named _my-experimental-changes_:

Bash Code

    git checkout -b my-experimental-changes
    

This command actually does two things: it creates the _my-experimental-changes_ branch, and it checks out the newly created branch. A _checkout_ means that the copy of the files you see in your folder will reflect what's in the branch. If you have two branches with different sets of changes, checking out one branch and then the other allows you to flip between the two sets of changes.

You can switch to an existing branch by using the `git checkout` command too. In this example, you check out the _main_ branch:

Bash Code

    git checkout main
    

Note

You normally need to commit your changes before you can check out a different branch. Git will warn you if you can't check out.

## Work on a branch

After you switch to a branch, you commit files just like normal. In fact, everything you've done up to now has been on a branch. You were working on the _main_ branch, which is the default branch when you create a new repository.

When you commit some changes while you've checked out a branch, the commit is associated with the branch. When you switch to a different branch, you probably won't see the commit in the `git log` history until you merge the branch.

## Merge branches

Branches are a great way to separate your in-progress work from the current live version of your Bicep code. But after you finish making changes to your files on a branch, you often want to merge the changes back to your _main_ branch.

When you're working on one branch, you can merge another branch's changes into your current branch by using the `git merge` command.

Note

Be sure to check out the merge destination branch (often called the _target_ branch) before you merge. Remember that you're merging _from_ another branch _into_ your current working branch.

Here's an example that shows how you can check out the _main_ branch, and then merge the changes from the _my-experimental-changes_ branch into the _main_ branch. Finally, you delete the _my-experimental-changes_ branch because you no longer need it.

Bash Code

    git checkout main
    git merge my-experimental-changes
    git branch -d my-experimental-changes
    

Tip

When you work with other people, it's common to use _pull requests_ to merge your changes instead of directly merging branches. You'll learn more about collaboration and pull requests shortly.

## Merge conflicts

When Git merges changes from one branch into another, it looks at the files that have been modified and it tries to merge the changes together. Sometimes, you might have made changes to the same lines of code on two different branches. In these situations, Git can't choose which is the correct version of the code, so it will instead create a _merge conflict_.

We don't discuss merge conflicts in depth in this module, but it's important to know that merge conflicts can happen. And it's more common when you collaborate with other people. In the summary for this module, we provide a link to more information about how Git and Visual Studio Code help you to resolve merge conflicts.

## Git workflows

In this module, you learn about only the basics of branches. However, branches are powerful and give you flexibility in how you work. For example, you can create branches off other branches, and merge a branch with any other branch. You can use branches to create all sorts of different _workflows_ that support the way you and your team like to work.

In this module, we're using a simple workflow called _trunk-based development_. In this workflow, you have a single _trunk_ branch. For example, we use _main_ in this article's examples. That branch represents the known-good version of your code. You create branches off this trunk when you make changes or do any work.

Trunk-based development discourages making changes directly on the trunk branch. You try to keep other branches around for only a short amount of time, which helps to minimize merge conflicts. Then you merge and delete those branches as you complete pieces of work.

There are other workflows that are common in team environments where you might want to control how often you release your changes. In the summary for this module, we provide links to more information about Git workflows.


# Exercise - Create and merge a branch

Back at the toy company, your website developers plan to add a new Azure Cosmos DB database to store data about the toys that the company sells. The developers asked you to update the Bicep code to add the Cosmos DB resources. However, they're not ready to make the changes yet. They just want you to get the changes ready for when they finish the modifications.

In this exercise, you'll add a new Bicep module on a branch of your repository. During the process, you'll:

-   Create a branch and switch to it.
-   Change your Bicep code on the branch.
-   Switch back to your main branch.
-   Merge your branch to _main_.

## Create and check out a branch in your repository

1.  By using the Visual Studio Code terminal, run the following command to create and check out a new branch:
    
    Bash Code
    
        git checkout -b add-database
        
    
2.  Run the following command to check the status of the repository:
    
    Bash Code
    
        git status
        
    
    The output looks similar to the following example:
    
    Output Copy
    
        On branch add-database
        nothing to commit, working tree clean
        
    
    The first line of the output tells you that Git is on the _add-database_ branch.
    
3.  In Visual Studio Code, look at the status bar at the bottom, left side of the window. Notice that the branch name changed to _add-database_.
    
    As with the other Git commands you've run, Visual Studio Code stays up to date with the changes in your Git repository, including when you check out a branch.
    

## Update a file on your branch

Now that you've created a branch, you'll add a new Bicep module for your website's Azure Cosmos DB account.

1.  In the _deploy_ folder's _modules_ subfolder, create a new file named _cosmos-db.bicep_.
    
2.  Open and save the empty _cosmos-db.bicep_ file so that Visual Studio Code loads the Bicep tooling.
    
3.  Copy the following code into _cosmos-db.bicep_:
    
    Bicep Copy
    
        @description('The Azure region into which the resources should be deployed.')
        param location string
        
        @description('The type of environment. This must be nonprod or prod.')
        @allowed([
          'nonprod'
          'prod'
        ])
        param environmentType string
        
        @description('The name of the Cosmos DB account. This name must be globally unique.')
        param cosmosDBAccountName string
        
        var cosmosDBDatabaseName = 'ProductCatalog'
        var cosmosDBDatabaseThroughput = (environmentType == 'prod') ? 1000 : 400
        var cosmosDBContainerName = 'Products'
        var cosmosDBContainerPartitionKey = '/productid'
        
        resource cosmosDBAccount 'Microsoft.DocumentDB/databaseAccounts@2024-11-15' = {
          name: cosmosDBAccountName
          location: location
          properties: {
            databaseAccountOfferType: 'Standard'
            locations: [
              {
                locationName: location
              }
            ]
          }
        }
        
        resource cosmosDBDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2024-11-15' = {
          parent: cosmosDBAccount
          name: cosmosDBDatabaseName
          properties: {
            resource: {
              id: cosmosDBDatabaseName
            }
            options: {
              throughput: cosmosDBDatabaseThroughput
            }
          }
        
          resource container 'containers' = {
            name: cosmosDBContainerName
            properties: {
              resource: {
                id: cosmosDBContainerName
                partitionKey: {
                  kind: 'Hash'
                  paths: [
                    cosmosDBContainerPartitionKey
                  ]
                }
              }
              options: {}
            }
          }
        }
        
    
4.  Save and close the _cosmos-db.bicep_ file.
    
5.  Open the _main.bicep_ file.
    
6.  Add the following parameter definitions below the `appServiceAppName` parameter definition:
    
    Bicep Copy
    
        @description('The name of the Cosmos DB account. This name must be globally unique.')
        param cosmosDBAccountName string = 'toyweb-${uniqueString(resourceGroup().id)}'
        
    
7.  Add the following module definition below the `appService` module definition:
    
    Bicep Copy
    
        module cosmosDB 'modules/cosmos-db.bicep' = {
          name: 'cosmos-db'
          params: {
            location: location
            environmentType: environmentType
            cosmosDBAccountName: cosmosDBAccountName
          }
        }
        
    
8.  Save and close the _main.bicep_ file.
    

## Review the differences and commit the changes

After you review the file differences, stage and commit your changes. You can choose whether to use the Git CLI or Visual Studio Code to commit the files. This example uses the Git CLI.

1.  Using **Source Control** in Visual Studio Code, look at the differences for both files.
    
    Notice the changed lines highlighted in the _main.bicep_ file.
    
2.  Review the files that are ready to commit.
    
    Bash Code
    
        git status
        
    
    The output will look like the following example.
    
    Output Copy
    
        On branch add-database
         Changes not staged for commit:
           (use "git add <file>..." to update what will be committed)
           (use "git restore <file>..." to discard changes in working directory)
                 modified:   deploy/main.bicep
        
         Untracked files:
           (use "git add <file>..." to include in what will be committed)
                 deploy/modules/cosmos-db.bicep
        
         no changes added to commit (use "git add" and/or "git commit -a")
        
    
3.  Stage the changes for both files.
    
    Bash Code
    
        git add .
        
    
    The dot (`.`) stages all files that were changed.
    
4.  Commit the changes.
    
    Bash Code
    
        git commit --message "Add Cosmos DB module"
        
    
    The output will look like the following example.
    
    Output Copy
    
        [add-database 513f700] Add Cosmos DB module
          2 files changed, 71 insertions(+)
          create mode 100644 deploy/modules/cosmos-db.bicep
        
    

## Switch branches

Now that you've made the changes on your branch, you can verify that the changes are visible only on the _add-database_ branch.

1.  Check out the _main_ branch. You can choose either of the following approaches:
    
    -   In the Visual Studio Code terminal window, enter the following command:
        
        Bash Code
        
            git checkout main
            
        
    -   In the Visual Studio Code status bar at the bottom of the window, select the branch name that currently displays _add-database_.
        
        A list of branches appears. Select the _main_ branch.
        
2.  In the Visual Studio Code **Explorer** pane, open the _main.bicep_ file.
    
    Notice that none of the Azure Cosmos DB changes you made are included. Now that you've switched to the _main_ branch, the database module isn't there. Don't worry, they're safely stored on your _add-database_ branch.
    

## Merge your branch

Your website team has tested the changes, and is now ready to launch the updated website with the Azure Cosmos DB database included. You'll merge the _add-database_ branch into the _main_ branch.

1.  Verify that you're on the _main_ branch by running `git status` and by looking at the branch name in the status bar.
    
2.  In the Visual Studio Code terminal, enter the following command to merge the changes from the _add-database_ branch onto the _main_ branch:
    
    Bash Code
    
        git merge add-database
        
    
3.  In the Visual Studio Code **Explorer** pane, open the _main.bicep_ file.
    
    Notice that the database module now appears in the file. You've now updated your known-good Bicep files, on your _main_ branch, to include the changes from your _add-database_ branch.
    
4.  In the Visual Studio Code terminal, enter the following command to delete the _add-database_ branch because you no longer need it:
    
    Bash Code
    
        git branch -d add-database


# Publish your repository to enable collaboration

You've learned how Git enables you to track the changes to your Bicep code. In this unit, you'll learn how Git also enables collaboration with your team members.

Note

The commands in this unit are shown to illustrate concepts. Don't run the commands yet. You'll practice what you learn here soon.

## What are GitHub and Azure Repos?

Git is software that you install and run on your own computer. As you've learned, Git keeps track of the changes you make to your files. It enables features like branching.

GitHub and Azure Repos are online services that keep copies of your Git repository and enable collaborative development. After you sign up for GitHub or Azure Repos, you continue to work with Git by using the same commands you've already been using. You continue working against your local Git repository. The difference is that you can synchronize your local Git repository with an online repository. You can also grant access to the online repository to other people, and you can control whether they can read or modify your code.

Note

Azure Repos is a feature of Azure DevOps. When you work with Azure Repos, you use the Azure DevOps website.

In a team environment, everyone on the team maintains their own local Git repository and synchronizes it with the online copy. In most situations, the online copy becomes the _source of truth_ for your team.

In a future module, you'll learn about deploying your Bicep code through an automated deployment pipeline. Pipelines require that your code is stored in an online repository. The pipeline accesses the code from there too.

Note

GitHub and Azure DevOps are both great options for hosting your Git repository. Your organization might already use one or the other. If you don't already have a preference, we recommend using GitHub because it's typically easier to get started.

## Local and remote repositories

When you work with repositories hosted in GitHub or Azure DevOps, you configure your local Git repository to know about the remote repository. An online repository has a URL that Git can use to access it from your computer. Conventionally, the term _origin_ refers to the remote repository that your local repository synchronizes with.

You also need to set up _tracking branches_ that tell Git a branch from your local repository represents the same branch as in your online repository. This tracking is especially important for your _main_ branch, because you want to keep that synchronized across all of your repositories. You can enable tracking on other branches too.

Note

Your team might have already created a repository that you want to view or modify. You can quickly get a copy of the repository by _cloning_ the online repository through the `git clone` command.

After you've configured your local repository and tracking branch, you can _push_ the contents of your local repository to the remote repository. And you can _pull_ the remote repository's changes into your local repository.

Note

The `git pull` operation downloads the changes from your remote repository and then merges the changes - just like when you merge branches. Occasionally you want to only download changes from the remote repository, such as when you want to update your local repository's list of remote branches. Use the `git fetch` command for that.

## Authentication

When you start working with online repositories, security becomes important. Source code for your infrastructure and applications is valuable, and it needs to be protected.

GitHub and Azure DevOps have comprehensive security processes. They both require that you authenticate before you start working with remote repositories hosted on their platforms.

The first time you try to work with a remote repository, you're prompted to sign in to GitHub or Azure DevOps. Some organizations protect their Git repositories with extra security checks like multifactor authentication. After you sign in, Git uses a component called Git Credential Manager to maintain your access so you don't need to sign in every time.

## Collaboration with others

After you set up your Git repository on GitHub or Azure Repos, you're ready to collaborate with others. There are many features that you can use to work with your team. One particular feature that you should know about is called _pull requests_, often shortened to _PRs_.

A pull request is effectively a controlled merge of two branches. GitHub or Azure Repos can enforce policies about who can merge and what kinds of changes can be merged.

A typical team workflow would involve a team member making changes to their code on a branch, and then creating a pull request to ask someone else to merge their changes into the _main_ branch. Other team members can see the list of changes in the PR. Those team members can even provide feedback on the changes or ask for revisions before they accept them. PRs provide a way to provide quality control around your team's code.

PRs and other collaboration features are outside the scope of this module, but we provide links to information about these features in the summary.


# Exercise - Publish your repository

Choose a repository hosting platform

 GitHub Azure Repos

At the toy company, the website's developers have offered to help you write the Bicep template. You told them you've been keeping the Bicep code in a repository, and they've asked you to publish the repository. In this exercise, you'll publish your Git repository so that so your colleagues can view the files and collaborate with you.

During the process, you'll:

-   Create a new remote repository.
-   Configure your local Git repository to integrate with the remote repository.
-   Push your changes from your local repository to the remote repository.
-   Verify that the changes appear in the remote repository.

## Create a repository in GitHub

1.  In a browser, go to [GitHub](https://www.github.com/). Sign in with your GitHub account, or create a new account if you don't have one.
    
2.  Select the plus (**+**) icon in the upper right of the window, and then select **New repository**.
    
    ![Screenshot of the GitHub interface that shows the menu for creating a new repository.](https://learn.microsoft.com/en-us/training/modules/manage-changes-bicep-code-git/media/9-github-new-repository-menu.png)
    
3.  Enter the details of your new repository:
    
    -   **Owner**: Select your GitHub user name from the drop-down menu. In the screenshot, `mygithubuser` is the repository owner's GitHub account name. You'll use your account name later in this module.
    -   **Repository name**: Enter a meaningful but short name. For this module, use `toy-website-workflow`.
    -   **Description**: Include a description to help others understand the repository's purpose.
    -   **Private**: You can use GitHub to create public and private repositories. Create a private repository, because only people inside your organization should access your toy website's files. You can grant access to others later.
    
    After you're done, your repository configuration should look like the following screenshot:
    
    ![Screenshot of the GitHub interface that shows the configuration for the repository to create.](https://learn.microsoft.com/en-us/training/modules/manage-changes-bicep-code-git/media/9-github-new-repository-details.png)
    
4.  Select **Create repository**.
    
5.  On the confirmation page that appears, make a note of the repository's URL. You can use the copy button to copy the URL. You'll use it shortly.
    
    ![Screenshot of the GitHub interface that shows the new repository's details, with the repository's URL highlighted.](https://learn.microsoft.com/en-us/training/modules/manage-changes-bicep-code-git/media/9-github-new-repository-confirmation.png)
    

## Create a repository in Azure Repos

1.  In a browser, go to [Azure DevOps](https://dev.azure.com/). Sign in or create a new account.
    
2.  If you're creating a new account, follow the prompts to create an Azure DevOps organization. Azure DevOps then asks you to create a new project. Continue to the next step.
    
    If you signed in to an existing Azure DevOps organization, select the **New project** button to create a new project.
    
    ![Screenshot of the Azure DevOps interface that shows the button to create a new project.](https://learn.microsoft.com/en-us/training/modules/manage-changes-bicep-code-git/media/9-azure-devops-create-project.png)
    
3.  Enter the details of your new project:
    
    -   **Project name**: Enter a meaningful but short name. For this module, use `toy-website`.
    -   **Description**: Include a description to help others understand the repository's purpose.
    -   **Visibility**: You can use Azure DevOps to create public and private repositories. Create a private repository, because only people inside your organization should access your website's files. You can grant access to others later.
    
    After you're done, your project configuration should look like the following screenshot:
    
    ![Screenshot of the Azure DevOps interface that shows the configuration for the project to create.](https://learn.microsoft.com/en-us/training/modules/manage-changes-bicep-code-git/media/9-azure-devops-new-project-details.png)
    
4.  Select **Create**.
    
5.  On the project page that appears, select the **Repos** menu item.
    
    ![Screenshot of the Azure DevOps interface that shows the menu on the project page, with the Repos item highlighted.](https://learn.microsoft.com/en-us/training/modules/manage-changes-bicep-code-git/media/9-azure-devops-repos-menu.png)
    
6.  Make a note of the repository's URL. You can use the copy button to copy the URL. You'll use it shortly.
    
    ![Screenshot of the Azure Repos interface that shows the repository's details, with the repository's U R L highlighted.](https://learn.microsoft.com/en-us/training/modules/manage-changes-bicep-code-git/media/9-azure-devops-repo-details.png)
    

## Generate a Git password

When you work with Azure Repos from Visual Studio Code on macOS, you need to use a special password that's different from the password that you use to sign in.

Note

If you're using Windows, skip to the next section, _Configure your local Git repository_.

1.  Select the **Generate Git credentials** button.
    
    Azure Repos creates a random password for you to use.
    
2.  Make a note of the **Password** value. You'll use it shortly.
    

Keep your browser open. You'll check on the repository again later in this exercise.

## Configure your local Git repository

1.  Ensure you're on the _main_ branch by entering the following command in the Visual Studio Code terminal:
    
    Bash Copy
    
        git checkout main
        
    
2.  Enter the following command to integrate your local repository with the remote repository that you created. Replace `YOUR_REPOSITORY_URL` with the URL that you saved earlier.
    
    Bash Copy
    
        git remote add origin YOUR_REPOSITORY_URL
        
    
    Notice that you're using the command `git remote add` to create a new reference to a remote repository. You name the reference `origin`, which is the standard name.
    
3.  Verify the remote was created.
    
    Bash Copy
    
        git remote -v
        
    
    The output will look like the example.
    
    Output Copy
    
        origin  https://github.com/mygithubuser/toy-website.git (fetch)
        origin  https://github.com/mygithubuser/toy-website.git (push)
        
    
    Output Copy
    
        origin https://myuser@dev.azure.com/myuser/toy-website/_git/toy-website (fetch)
        origin https://myuser@dev.azure.com/myuser/toy-website/_git/toy-website (push)
        
    

## Push your changes by using the Git CLI

1.  In the Visual Studio Code terminal, enter the following command:
    
    Bash Copy
    
        git push -u origin main
        
    
    Because your current local branch is _main_, this command tells Git that your local _main_ branch _tracks_ the _main_ branch in your remote repository. It also _pushes_ the commits from your local repository to the remote repository.
    
2.  This is the first time you've used this remote repository, so the terminal prompts you to select how to authenticate. Choose the option to use the browser.
    
3.  Follow the instructions in the browser to sign in and authorize Visual Studio Code to access your GitHub repository.
    
4.  In your terminal window, Git displays output similar to the following example:
    
    Output Copy
    
        Enumerating objects: 16, done.
        Counting objects: 100% (16/16), done.
        Delta compression using up to 8 threads
        Compressing objects: 100% (11/11), done.
        Writing objects: 100% (16/16), 2.30 KiB | 785.00 KiB/s, done.
        Total 16 (delta 2), reused 0 (delta 0), pack-reused 0
        remote: Resolving deltas: 100% (2/2), done.
        To https://github.com/mygithubuser/toy-website.git
         * [new branch]      main -> main
        Branch 'main' set up to track remote branch 'main' from 'origin'.
        
    
    This output indicates that Git successfully pushed the contents of your repository to the remote repository.
    

1.  In the Visual Studio Code terminal, enter the following command:
    
    Bash Copy
    
        git push -u origin main
        
    
    Because your current local branch is _main_, this command tells Git that your local _main_ branch _tracks_ the _main_ branch in your remote repository. It also _pushes_ the commits from your local repository to the remote.
    
2.  This is the first time you've used this repository, so you're prompted to sign in.
    
    If you're using Windows, enter the same credentials that you used to sign in to Azure DevOps earlier in this exercise.
    
    If you're using macOS, paste the password that you generated earlier in this exercise.
    
3.  In your terminal window, Git displays output similar to the following example:
    
    Output Copy
    
        Enumerating objects: 16, done.
        Counting objects: 100% (16/16), done.
        Delta compression using up to 8 threads
        Compressing objects: 100% (11/11), done.
        Writing objects: 100% (16/16), 2.30 KiB | 785.00 KiB/s, done.
        Total 16 (delta 2), reused 0 (delta 0), pack-reused 0
        remote: Analyzing objects... (16/16) (5 ms)
        remote: Storing packfile... done (165 ms)
        remote: Storing index... done (75 ms)
        To https://dev.azure.com/myuser/toy-website/_git/toy-website
         * [new branch]      main -> main
        Branch 'main' set up to track remote branch 'main' from 'origin'.
        
    
    This output indicates that Git successfully pushed the contents of your repository to the remote repository.
    

## Add a README file

Now that your colleagues will use your repository, it's important to create a _README.md_ file to help them understand what your repository is for and how they can get started.

1.  Open **Explorer** in Visual Studio Code.
    
2.  Add a new file at the root of your current folder structure, and name it _README.md_.
    
3.  Copy the following text into the file:
    
    markdown Copy
    
        # Toy company's website
        
        This repository contains the website for our toy company.
        
        ## How to use
        
        The Azure infrastructure is defined using [Bicep](/azure/azure-resource-manager/bicep).
        
        To deploy the website's Azure resources, use the _deploy/main.bicep_ file.
        
    
    Tip
    
    This is a placeholder README file, so it doesn't have a lot of useful content. When you work with your own Git repositories, create a README file that helps someone understand how to get started with your code. Think of it as a lightweight manual for your project.
    
4.  Save the file.
    
5.  Stage and commit the file to your local Git repository. You can choose whether you commit by using the Git CLI or by using **Source Control** in Visual Studio Code.
    

## Push again by using Visual Studio Code

Now that you've committed a new file, you need to push your changes again so that the remote has the latest files. This time, you use Visual Studio Code to push to the remote repository.

1.  Open **Source Control** in Visual Studio Code.
    
2.  Select the icon with three dots on the right side of the **Source Control** toolbar, and then select **Push**.
    
    ![Screenshot of Visual Studio Code that shows the Source Control menu, with the Push menu item highlighted.](https://learn.microsoft.com/en-us/training/modules/manage-changes-bicep-code-git/media/9-vscode-push.png)
    
    Notice that you're not prompted to sign in again. Your credentials are shared between the Git CLI and Visual Studio Code.
    

## Verify the changes in GitHub

Now that you've pushed your changes to your remote repository, you can inspect the contents of the repository on GitHub.

1.  In your browser, refresh the repository's page.
    
2.  Notice that the files you created are now listed, and your _README.md_ file is displayed.
    
    ![Screenshot of the GitHub interface that shows the repository, including the folder and file structure.](https://learn.microsoft.com/en-us/training/modules/manage-changes-bicep-code-git/media/9-github-final.png)
    
3.  Browse through the GitHub interface to explore the files, and notice that your changes are all displayed. Because GitHub has the full list of changes to each file, you can even view the history of a file, just as you can when you work in Visual Studio Code.


# Module assessment

1. 

Which of these statements is a benefit of using version control?

- You can manage multiple environments with a single template by using branches.

- -> You can view the history of your files and revert to a previous version.

- You can create smaller reusable Bicep files.

2. 

You've been asked to try out a new Azure service. You're going to temporarily add it to a Bicep file that you've already created and added to your Git repository. What should you do?

- -> Create a new branch in your existing repository and make your changes on the branch.

- Initialize a new Git repository and add the updated file to that.

- Copy the file out of your Git repository and onto your desktop or another folder. Make the changes there.

3. 

Your team has decided to adopt trunk-based development. Which of these statements is true?

- Trunk-based development eliminates the possibility of merge conflicts.

- Trunk-based development encourages you to use long-lived branches.

- -> Trunk-based development encourages you to use short-lived branches.

4. 

A colleague has created a repository on GitHub and has granted you access. You want to make a local copy of the repository so that you can add some Bicep files to it. Which of these commands should you run first?

- -> `git clone`

- `git pull`

- `git remote add upstream`


# Summary

Thanks to your efforts, your toy company has a large set of Bicep files to deploy all aspects of its Azure infrastructure. Managing these files has been a challenge, though, and you needed a way to keep track of your changes.

In this module, you learned how the Git version control system can be used with Bicep code to provide a repository for your deployment templates. You learned about the benefits of using Git with Bicep code, and how Git can scale from an individual to an entire organization.

You used Visual Studio Code to initialize a Git repository, added and updated some files, viewed their history, and created a branch. You then merged that branch. Finally, you published your Git repository so that your colleagues can access it. Publishing the repository will also enable you to use a deployment pipeline in the future.

Now, whenever you make changes to your Bicep templates, you can be sure that your updates are tracked and that you can see older versions of your files. You can even use branches to work on experimental changes without breaking the current known-good files.

## Learn more

There's a lot more to know about Git's capabilities for working with deployment templates and scripts. As you continue to learn about Bicep and infrastructure as code, it's important to also learn about version control:

-   The module [Use Git version-control tools in Visual Studio Code](https://learn.microsoft.com/en-us/training/modules/use-git-from-vs-code/) provides more information on Git integration into Visual Studio Code.

The following features of Git are useful when you work with infrastructure as code:

-   [Staging your changes](https://code.visualstudio.com/docs/introvideos/versioncontrol), which enables you to commit only some of the things you've changed while leaving others out of the commit.
-   [Stashing your changes](https://git-scm.com/book/en/v2/Git-Tools-Stashing-and-Cleaning), which enables you to keep your changes without committing them.
-   [Undoing changes](https://git-scm.com/book/en/v2/Git-Basics-Undoing-Things), including reverting commits and resetting your repository status.
-   [Branches](https://git-scm.com/book/en/v2/Git-Branching-Basic-Branching-and-Merging), including [handling merge conflicts](https://docs.github.com/github/collaborating-with-pull-requests/addressing-merge-conflicts/resolving-a-merge-conflict-using-the-command-line), [advanced merging](https://git-scm.com/book/en/v2/Git-Tools-Advanced-Merging), and [rebasing](https://git-scm.com/book/en/v2/Git-Branching-Rebasing).
-   [Branching workflows](https://git-scm.com/book/en/v2/Git-Branching-Branching-Workflows) to support your team's ways of working. We introduced [trunk-based development](https://trunkbaseddevelopment.com/) in this module, but some teams prefer the [GitHub Flow](https://docs.github.com/get-started/quickstart/github-flow) model. [Consider some best practices when selecting your branching strategy](https://learn.microsoft.com/en-us/azure/devops/repos/git/git-branching-guidance).
-   [Rewriting history](https://git-scm.com/book/en/v2/Git-Tools-Rewriting-History), including amending commit messages and removing information from your commit history, and squashing changes.
-   [Submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules).

Much of the power of Git comes from its use in team environments. Specific features you'll likely work with include:

-   Cloning repositories ([GitHub](https://docs.github.com/github/creating-cloning-and-archiving-repositories/cloning-a-repository-from-github/cloning-a-repository), [Azure Repos](https://learn.microsoft.com/en-us/azure/devops/repos/git/clone)).
-   Pull requests ([GitHub](https://docs.github.com/github/collaborating-with-pull-requests/), [Azure Repos](https://learn.microsoft.com/en-us/azure/devops/repos/git/pull-requests)).
-   Forking repositories ([GitHub](https://docs.github.com/get-started/quickstart/fork-a-repo), [Azure Repos](https://learn.microsoft.com/en-us/azure/devops/repos/git/forks)).


