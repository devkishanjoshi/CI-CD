FROM node:12

# Create my_app directory
WORKDIR /my_app

# Install app dependencies
COPY package*.json ./
RUN npm install

# Copy files
COPY server.js ./

# Expose the Port defined in app
EXPOSE 8085

# Command to start the app
CMD [ "npm", "start" ]