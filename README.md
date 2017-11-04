"# awsbackup" 
Write a Bash/Python script using AWS SDK that will do the following:

Create an AMI of the EC2 instances for backup based on tag “Backup” (if set to “true” - instance should be backup).
Script should not reboot the servers and set a descriptive name for the AMI based on the Name of the ec2 instance along with the date.
AMIs older than 7 days should be removed.
The full list of AMIs should be printed on the final output - the old ones should be highlighted yellow, new ones - by green colors.

Push the final code version to a public GitHub repository and share URL link to it.
 Junior Devops Engineer
 
