error id: file://<HOME>/Dropbox/Classes/Software%20Architecture/Assignments/Assignment%201/software-architecture-web-application/load-testing/simulations/WebApplicationLoadTest.scala:scala/concurrent/
file://<HOME>/Dropbox/Classes/Software%20Architecture/Assignments/Assignment%201/software-architecture-web-application/load-testing/simulations/WebApplicationLoadTest.scala
empty definition using pc, found symbol in pc: 
empty definition using semanticdb
empty definition using fallback
non-local guesses:

offset: 81
uri: file://<HOME>/Dropbox/Classes/Software%20Architecture/Assignments/Assignment%201/software-architecture-web-application/load-testing/simulations/WebApplicationLoadTest.scala
text:
```scala
import io.gatling.core.Predef._
import io.gatling.http.Predef._
import scala.conc@@urrent.duration._

class WebApplicationLoadTest extends Simulation {

  // Get configuration from system properties
  val baseUrl = System.getProperty("baseUrl", "http://web_application_app:4000")
  val users = System.getProperty("users", "10").toInt
  val duration = System.getProperty("duration", "5").toInt

  // HTTP configuration
  val httpProtocol = http
    .baseUrl(baseUrl)
    .acceptHeader(
      "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
    )
    .acceptLanguageHeader("en-US,en;q=0.5")
    .acceptEncodingHeader("gzip, deflate")
    .userAgentHeader("Gatling Load Test")

  // Simple scenario that tests main application endpoints
  val basicScenario = scenario("Basic User Journey")
    .exec(
      http("Home Page")
        .get("/")
        .check(status.is(200))
    )
    .pause(1)
    .exec(
      http("Books List")
        .get("/books")
        .check(status.is(200))
    )
    .pause(2)
    .exec(
      http("Authors List")
        .get("/authors")
        .check(status.is(200))
    )
    .pause(1)
    .exec(
      http("Reviews List")
        .get("/reviews")
        .check(status.is(200))
    )
    .pause(1)
    .exec(
      http("Sales List")
        .get("/sales")
        .check(status.is(200))
    )

  // Setup the load test
  setUp(
    basicScenario.inject(
      rampUsers(users).during(duration.minutes)
    )
  ).protocols(httpProtocol)
    .maxDuration((duration + 2).minutes)
    .assertions(
      global.responseTime.max.lt(10000),
      global.responseTime.mean.lt(3000),
      global.successfulRequests.percent.gt(90)
    )
}

```


#### Short summary: 

empty definition using pc, found symbol in pc: 