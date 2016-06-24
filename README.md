### Purpose and Audience
This image provides a relatively lightweight .NET Core-only runtime environment. The instructions provided pertain to Ubuntu Xenial based developers using VS Code as their primary development environment.

#### Docker Compatibility
The image has been tested with Docker version 1.10.3. However, Ubuntu recommends Docker 1.11.2 or higher.

#### Size
This image is approximately 382 MB

### Development Environment
The development environment should closely mirror the version of the runtime available in the container. Substantial version mismatches, especially within the Framework version will cause deployment failures.

Xenial is now supported by the .NET Core project with no manual installation of missing libraries:

```
sudo sh -c 'echo "deb [arch=amd64] https://apt-mo.trafficmanager.net/repos/dotnet/ xenial main" > /etc/apt/sources.list.d/dotnetdev.list'
sudo apt-key adv --keyserver apt-mo.trafficmanager.net --recv-keys 417A0893
sudo apt-get update
```
  
  Then:
```
sudo apt install dotnet-dev-1.0.0-preview2-003121
suod apt install dotnet-sharedframework-microsoft.netcore.app-1.0.0
```


### .NET Core Project Compatibility
Applications using this environment should use the following Framework entry in the `project.json`

```json
"frameworks": {
    "netcoreapp1.0": {
      "dependencies": {
        "Microsoft.NETCore.App": {
          "type": "platform",
          "version": "1.0.0"
        }
      },
      "imports": "dnxcore50"
    }
  }
```


### Application deployment
To use this image as part of an application deployment the following are key tasks and techniques:

1. Create a Release configuration
2. Re-locate NuGet packages for easy access
3. Dockerfile construction
4. Testing and debugging images

#### Release configuration
The "stock" `project.json` does not come with a "configurations" section. To create a Release configuration add the following section to the `project.json` file:

```json
{"frameworks": { },
"configurations": {
    "Debug": {
      "buildOptions": {
        "define": ["DEBUG", "TRACE"]
      }
    },
    "Release": {
      "buildOptions": {
        "define": ["RELEASE", "TRACE"],
        "outputName": "app",
        "optimize": true
      }
    }
  }
}
```
A more complete explanation of some of the newer options can be found here: https://github.com/aspnet/Announcements/issues/175

The one item of note here is the "outputName" property. This field will dictate the name of the DLL that is generated at compile time. If the name of the application is kept consistent then the core docker file used in deployment can be more easily modified for other projects.

#### Relocate NuGet packages
To simplify deployment, locate the NuGet packages in the Project folder using 

`dotnet restore --packages ./lib`.

This step is *required* since the container does not have the SDK installed and is unable to execute `dotnet restore` for the project.

The NuGet files will occupy the most space in the resulting Docker image.

#### Dockerfile construction
The dockerfile for the resulting application is fairly straight forward. By convention the application is placed in `/app/`. This location is arbitrary. Any additional assets can be placed under this directory. When the application is run, paths are relative to this directory. The use of environment variables is recommended for deployments.

```Dockerfile
FROM 42north/ubuntu-xenial-dcp:1.0.0
#  Copy the key build products required to start the application
COPY bin/Release/netcoreapp1.0/app.dll /app/
COPY bin/Release/netcoreapp1.0/app.deps.json /app/
COPY bin/Release/netcoreapp1.0/app.runtimeconfig.json /app/
# Copy the contents of the restored NuGet packages
COPY lib/ /app/lib
# Copy any additional required directories
COPY data /app/data
# This entry point will start your application 
# and use /app/lib as the path to locate dependent assemblies
ENTRYPOINT dotnet --additionalprobingpath /app/lib /app/app.dll
```

A sample application using this technique can be found on GitHub:

https://github.com/42north/ubuntu-xenial-dcp-sample-app#ubuntu-xenial-dcp-sample-app

#### Debugging and Troubleshooting

##### Docker Attach

`sudo docker run -it --entrypoint /bin/bash [my image tag]`

This will override the entry point command in the docker file for the application and run bash instead.

##### Enable Tracing

`export COREHOST_TRACE=1`

This can help identify otherwise vague errors during application startup.


 
