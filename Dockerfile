FROM node:latest
WORKDIR  /app
COPY . /app
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "start"]


#sudo docker build -t reactapp reactapp/
#sudo docker run -d --rm -p 3000:3000 reactapp 