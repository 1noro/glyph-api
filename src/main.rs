#[macro_use] extern crate rocket;

#[get("/healthcheck")]
fn health_check() -> &'static str {
    "OK\n"
}

#[launch]
fn rocket() -> _ {
    rocket::build().mount("/v1", routes![health_check])
}
