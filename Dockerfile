FROM mcr.microsoft.com/powershell:7.4-ubuntu-22.04

RUN apt-get update && \
    apt-get install -y p7zip-full && \
    pwsh -Command Install-Module -Force -Name Pester && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
COPY . .

CMD ["pwsh", "-Command", "Invoke-Pester ./tests/archive-artifacts.Tests.ps1 -Output Detailed"]