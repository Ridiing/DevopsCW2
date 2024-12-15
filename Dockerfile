# Use the Node.js 14 image as the base
FROM node:14

# Set the working directory in the container
WORKDIR /app

# Copy the application code into the container
COPY . .

# Install dependencies (if any are defined in package.json)
RUN npm install


# Start the application
CMD ["node", "server.js"]

#Expose port 
EXPOSE 8080
