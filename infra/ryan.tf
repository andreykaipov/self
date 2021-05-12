resource "cloudflare_worker_script" "ryan" {
  name    = "hello-ryan"
  content = file("js/ryan.js")
}

resource "cloudflare_worker_route" "ryan" {
  zone_id     = cloudflare_zone.kaipov.id
  pattern     = "${cloudflare_zone.kaipov.zone}/ryan"
  script_name = cloudflare_worker_script.ryan.name
}
