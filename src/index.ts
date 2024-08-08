import {
  resolve,
  dirname,
  join
} from "node:path"

import {
  mkdir,
  exists
} from "node:fs/promises"


async function download(
  destiny : string
) {
  const uri = resolve(destiny)

  const today = await fetch(
    "https://image-api-aberigle.vercel.app/api/image"
  )
  .then(result => result.json())
  .then(({ images = [] }) => images[0])

  if (!today) throw new Error("Error downloading the image")

  const url: URL = new URL("https://bing.com" + today.url.replaceAll("1920x1080", "UHD"))

  const filename : string = url.searchParams.get("id") as string

  await ensurePath(uri)

  const blob = await fetch(url)
  .then(result => result.blob())

  await Bun.write(join(uri, filename), blob)

  return join(uri, filename)
}


async function ensurePath(
  uri : string
) {
  if (await exists(uri)) return true

  const parent = dirname(uri)
  if (parent !== "/") await ensurePath(parent)

  await mkdir(uri)

  return ensurePath(uri)
}


(async () => {
  const filename = await download(process.argv[2] || "/home/aberigle/.local/share/backgrounds")
  console.log(filename)

})()
