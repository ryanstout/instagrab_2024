FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Install git
RUN apt-get update && apt-get install -y git

# Clone the repository
RUN git clone https://github.com/proxidize/proxidize-android.git .

# Replace the server.ini file
RUN echo '[common]\nbind_port = 29204\nauthentication_method=token\ntoken = 1234567822' > server/server.ini

# Ensure the server binary has executable permissions
RUN chmod +x server/server

# Expose the port the server runs on
EXPOSE 29204
EXPOSE 16310
EXPOSE 14169
EXPOSE 40444

# Start a shell when the container launches
CMD ["bash", "-c", "cd server && ./server -c server.ini > logs.txt"]
