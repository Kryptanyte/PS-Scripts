#Make sure your in the same directory as the file for docker, This will be from the download of docker
#The download for docker will be at: https://download.docker.com/components/engine/windows-server/17.06/docker-17.06.2-ee-6.zip
#Also make sure to chnage directory, most commonly found in: C:\Users\%USER%\Downloads

Expand-Archive docker-17.06.2-ee-6.zip -DestinationPath $Env:ProgramFiles

Remove-Item -Force docker-17.06.2-ee-6.zip

$null = Install-WindowsFeature containers

$env:path += ";$env:ProgramFiles\docker"

# Optionally, modify PATH to persist across sessions, take head when running this next session...


$newPath = "$env:ProgramFiles\docker;" +
[Environment]::GetEnvironmentVariable("PATH",
[EnvironmentVariableTarget]::Machine)

[Environment]::SetEnvironmentVariable("PATH", $newPath,
[EnvironmentVariableTarget]::Machine)


dockerd --register-service

Start-Service docker

#Use this to test the docker EE enviroment: 

docker container run hello-world:nanoserver

#There are also update procedures, use this command here:

Install-Package -Name docker -ProviderName DockerMsftProvider -Update -Force
