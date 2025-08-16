FROM node:18-alpine

WORKDIR /app

COPY package.json package.json
RUN npm install

COPY index.js index.js

EXPOSE 5000
CMD ["npm", "start"]
