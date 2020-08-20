package laser2

import grails.boot.GrailsApp
import grails.boot.config.GrailsAutoConfiguration
import org.springframework.context.EnvironmentAware
import org.springframework.core.env.Environment
import org.springframework.core.env.MapPropertySource

class Application extends GrailsAutoConfiguration implements EnvironmentAware {

    static void main(String[] args) {
        GrailsApp.run(Application, args)
    }

    @Override
    void setEnvironment(Environment environment) {
        //String infoAppName = grailsApplication.metadata.get('info.app.name')
        String infoAppName = 'laser2'
        File externalConfig = new File("${System.getProperty('user.home')}/.grails/${infoAppName}-config.groovy")

        if (externalConfig.exists()) {
            log.info("Loading external configuration from: ${externalConfig.absolutePath}")
            ConfigObject config = new ConfigSlurper().parse(externalConfig.toURL())
            environment.propertySources.addFirst(new MapPropertySource("externalGroovyConfig", config))
        }
        else {
            log.warn("External config could not be found, checked ${externalConfig.absolutePath}")
        }
    }
}
