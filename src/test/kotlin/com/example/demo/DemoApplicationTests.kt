package com.example.demo

import io.qameta.allure.Allure
import io.qameta.allure.Step
import org.junit.jupiter.api.Test
import org.springframework.boot.test.context.SpringBootTest


@SpringBootTest
class DemoApplicationTests {

	@Test
	fun contextLoads() {
		Allure.step("Проверка загрузки контекста Spring")
	}

}
