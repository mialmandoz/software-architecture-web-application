file://<HOME>/Dropbox/Classes/Software%20Architecture/Assignments/Assignment%201/software-architecture-web-application/load-testing/simulations/WebApplicationLoadTest.scala
empty definition using pc, found symbol in pc: 
semanticdb not found
empty definition using fallback
non-local guesses:
	 -io/gatling/core/Predef.io.gatling.
	 -io/gatling/http/Predef.io.gatling.
	 -scala/concurrent/duration/io/gatling.
	 -io/gatling.
	 -scala/Predef.io.gatling.
offset: 12
uri: file://<HOME>/Dropbox/Classes/Software%20Architecture/Assignments/Assignment%201/software-architecture-web-application/load-testing/simulations/WebApplicationLoadTest.scala
text:
```scala
import io.ga@@tling.core.Predef._
import io.gatling.http.Predef._
import scala.concurrent.duration._

class WebApplicationLoadTest extends Simulation {

  // HTTP configuration
  val httpProtocol = http
    .baseUrl("http://web_application_nginx_app") // Default to nginx setup
    .acceptHeader("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8")
    .acceptLanguageHeader("en-US,en;q=0.5")
    .acceptEncodingHeader("gzip, deflate")
    .userAgentHeader("Gatling Load Test")

  // Scenarios
  val browseBooks = scenario("Browse Books")
    .exec(http("Home Page")
      .get("/")
      .check(status.is(200)))
    .pause(1)
    .exec(http("Books List")
      .get("/books")
      .check(status.is(200)))
    .pause(2)
    .exec(http("Books Page 2")
      .get("/books?page=2")
      .check(status.is(200)))
    .pause(1)

  val searchBooks = scenario("Search Books")
    .exec(http("Home Page")
      .get("/")
      .check(status.is(200)))
    .pause(1)
    .exec(http("Search Books")
      .get("/books/search?query=programming")
      .check(status.is(200)))
    .pause(2)
    .exec(http("Advanced Search")
      .get("/books/search?query=elixir&field=title")
      .check(status.is(200)))
    .pause(1)

  val browseAuthors = scenario("Browse Authors")
    .exec(http("Authors List")
      .get("/authors")
      .check(status.is(200)))
    .pause(2)
    .exec(http("Authors Page 2")
      .get("/authors?page=2")
      .check(status.is(200)))
    .pause(1)

  val browseReviews = scenario("Browse Reviews")
    .exec(http("Reviews List")
      .get("/reviews")
      .check(status.is(200)))
    .pause(2)
    .exec(http("Reviews Search")
      .get("/reviews/search?query=excellent")
      .check(status.is(200)))
    .pause(1)

  val browseSales = scenario("Browse Sales")
    .exec(http("Sales List")
      .get("/sales")
      .check(status.is(200)))
    .pause(2)
    .exec(http("Filter Sales by Year")
      .get("/sales?filter_year=2024")
      .check(status.is(200)))
    .pause(1)

  // Load test configurations
  val lightLoad = scenario("Light Load Mix")
    .exec(
      randomSwitch(
        40.0 -> exec(browseBooks),
        25.0 -> exec(searchBooks),
        15.0 -> exec(browseAuthors),
        15.0 -> exec(browseReviews),
        5.0 -> exec(browseSales)
      )
    )

  // Test execution based on system property
  val testType = System.getProperty("testType", "ramp")
  val baseUrl = System.getProperty("baseUrl", "http://web_application_nginx_app")
  val users = System.getProperty("users", "10").toInt
  val duration = System.getProperty("duration", "5").toInt

  // Update base URL
  val updatedHttpProtocol = httpProtocol.baseUrl(baseUrl)

  setUp(
    testType match {
      case "spike" => 
        lightLoad.inject(
          nothingFor(10.seconds),
          atOnceUsers(users)
        )
      case "stress" =>
        lightLoad.inject(
          rampUsers(users).during(duration.minutes)
        )
      case "ramp" =>
        lightLoad.inject(
          rampUsers(users).during(duration.minutes)
        )
      case _ =>
        lightLoad.inject(
          rampUsers(users).during(duration.minutes)
        )
    }
  ).protocols(updatedHttpProtocol)
   .maxDuration(10.minutes)
   .assertions(
     global.responseTime.max.lt(5000),
     global.responseTime.mean.lt(1000),
     global.successfulRequests.percent.gt(95)
   )
}

```


#### Short summary: 

empty definition using pc, found symbol in pc: 