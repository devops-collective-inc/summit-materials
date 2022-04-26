FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build-env
WORKDIR /app

COPY ./mywebapp/*.csproj ./
RUN dotnet restore

COPY ./mywebapp/ ./
RUN dotnet publish -c Release -o out

FROM mcr.microsoft.com/dotnet/core/aspnet:3.1
WORKDIR /app
COPY --from=build-env /app/out ./mywebapp/
ENTRYPOINT ["dotnet", "./mywebapp/webapp.dll"]
