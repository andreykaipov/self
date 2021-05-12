async function handleRequest(request) {
  const data = {
    hello: "ryan",
    info: 1234,
  }

  const json = JSON.stringify(data)

  return new Response(json, {
    headers: {
      "content-type": "application/json;charset=UTF-8"
    }
  })
}

addEventListener("fetch", async event => {
  event.respondWith(handleRequest(event.request))
})
