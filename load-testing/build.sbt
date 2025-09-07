ThisBuild / scalaVersion := "2.13.12"

lazy val gatlingVersion = "3.9.5"

lazy val root = (project in file("."))
  .settings(
    name := "web-application-load-test",
    libraryDependencies ++= Seq(
      "io.gatling.highcharts" % "gatling-charts-highcharts" % gatlingVersion,
      "io.gatling" % "gatling-test-framework" % gatlingVersion,
      "io.gatling" % "gatling-core" % gatlingVersion,
      "io.gatling" % "gatling-http" % gatlingVersion
    )
  )
