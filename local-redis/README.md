# Local Redis for testing

This (admittedly poorly conceived) artifact is a jar that pulls in an embededded redis jar, and overwrites the linux
binary with one that was compiled and is compatible with CentOS 6.5.

Improvements in the way this functions are welcome, but this is used in many tests for EzBake, so please submit merge
request.

## Dependencies

```xml
<dependency>
    <groupId>redis.embedded</groupId>
    <artifactId>embedded-redis</artifactId>
    <version>0.2</version>
</dependency>
```