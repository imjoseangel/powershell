Configuration FileResourceDemo
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Node "localhost"
    {
        File DirectoryCopy
        {
            Ensure = "Present"  # You can also set Ensure to "Absent"
            Type = "Directory" # Default is "File".
            Recurse = $true # Ensure presence of subdirectories, too
            SourcePath = "C:\Users\josemar\Documents\Shortcuts"
            DestinationPath = "C:\Users\josemar\Documents\Shortcutx"    
        }

        Log AfterDirectoryCopy
        {
            # The message below gets written to the Microsoft-Windows-Desired State Configuration/Analytic log
            Message = "Finished running the file resource with ID DirectoryCopy"
            DependsOn = "[File]DirectoryCopy" # This means run "DirectoryCopy" first.
        }
    }
}

# Compile the configuration file to a MOF format
FileResourceDemo

# Run the configuration on localhost
Start-DscConfiguration -Path .\FileResourceDemo -Wait -Force -Verbose
