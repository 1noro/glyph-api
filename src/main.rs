#[macro_use] extern crate rocket;

use rocket::serde::{Serialize, json::Json};

#[derive(Serialize)]
#[serde(crate = "rocket::serde")]
struct Status {
    status: &'static str
}

#[get("/healthcheck", format = "application/json")]
fn health_check_json() -> Json<Status> {
    Json(Status { status: "OK" })
}

#[get("/healthcheck", format = "text/plain", rank = 2)]
fn health_check_plain() -> &'static str {
    "OK"
}

#[launch]
fn rocket() -> _ {
    rocket::build().mount("/v1", routes![health_check_json, health_check_plain])
}
