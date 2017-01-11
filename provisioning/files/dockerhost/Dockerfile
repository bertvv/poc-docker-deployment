# Dockerfile for .Net application container

FROM microsoft/dotnet:1.0.1-sdk-projectjson

# Create directory for the app source code
RUN mkdir -p /app
WORKDIR /app

# Copy the source and restore dependencies
COPY . /app

ENV ASPNETCORE_ENVIRONMENT="Production"
RUN dotnet restore

# Expose the port and start the app
EXPOSE 5000
CMD [ "dotnet", "run" ]

