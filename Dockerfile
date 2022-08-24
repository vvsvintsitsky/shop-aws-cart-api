### Build

FROM node:16-alpine As build

RUN mkdir -p /usr/src/app

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm ci

COPY tsconfig*.json nest-cli.json ./
COPY ./src ./src

RUN npm run build

### Production

FROM node:16-alpine

ARG USERGROUP="nodegroup"
ARG USER="nodeuser"
ARG WORKDIR="/usr/src/app"

WORKDIR ${WORKDIR}

RUN addgroup -S ${USERGROUP}
RUN adduser -S -D -h ${WORKDIR} ${USER} ${USERGROUP}

RUN chown -R $USER:$USERGROUP ${WORKDIR}

ENV NODE_ENV production

COPY package*.json ./

RUN npm ci --only=production

COPY --from=build /usr/src/app/dist ./dist

USER ${USER}

EXPOSE 4000

CMD [ "node", "dist/main.js" ]