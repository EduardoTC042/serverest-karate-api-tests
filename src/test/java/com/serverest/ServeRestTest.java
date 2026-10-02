package com.serverest;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Runner único de la suite. Ejecuta en paralelo todos los features de
 * com/serverest/usuarios, excluyendo los helpers (@ignore).
 *
 * Filtrar por tags:   mvn test -Dkarate.options="--tags @smoke"
 * Cambiar hilos:      mvn test -Dthreads=2
 * Cambiar entorno:    mvn test -Dkarate.env=local
 */
class ServeRestTest {

    @Test
    void ejecutarSuiteUsuarios() {
        int threads = Integer.parseInt(System.getProperty("threads", "4"));
        Results results = Runner.path("classpath:com/serverest/usuarios")
                .tags("~@ignore")
                .outputCucumberJson(true)
                .outputJunitXml(true)
                .parallel(threads);
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }
}
