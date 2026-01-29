FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS base
WORKDIR /app
EXPOSE 5000

FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src
COPY backend/Hypesoft.slnx ./
COPY backend/src ./src
RUN dotnet restore "./src/Hypesoft.API/Hypesoft.API.csproj"
RUN dotnet publish "./src/Hypesoft.API/Hypesoft.API.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
ENV ASPNETCORE_URLS=http://+:5000
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "Hypesoft.API.dll"]
