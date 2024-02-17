FROM node:latest
WORKDIR  /app
COPY reactapp /app
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "start"]