#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.
#FROM surnet/alpine-wkhtmltopdf:3.9-0.12.5-full as wkhtmltopdf
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-buster-slim AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/core/sdk:3.1-buster AS build
WORKDIR /src
COPY ["PDFDemo.csproj", "./"]
RUN dotnet restore "PDFDemo.csproj"
COPY . .
WORKDIR "/src/"
RUN dotnet build "PDFDemo.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "PDFDemo.csproj" -c Release -o /app/publish



FROM base AS final
###### wkhtmltopdf part
RUN apt-get update

RUN apt-get install wget libgdiplus -y

RUN wget -P /app https://github.com/rdvojmoc/DinkToPdf/raw/master/v0.12.4/64%20bit/libwkhtmltox.dll

RUN wget -P /app https://github.com/rdvojmoc/DinkToPdf/raw/master/v0.12.4/64%20bit/libwkhtmltox.dylib

RUN wget -P /app https://github.com/rdvojmoc/DinkToPdf/raw/master/v0.12.4/64%20bit/libwkhtmltox.so
WORKDIR /app

COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "PDFDemo.dll"]
