create database MMORPG;
use MMORPG;

/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/***********************CREATE TABLES**************************************/

CREATE TABLE CUENTAS (
	id INT IDENTITY(1,1) NOT NULL,
	nombre_usuario VARCHAR(30) UNIQUE NOT NULL,
	contrasenia VARCHAR(30) NOT NULL,
	email VARCHAR(50) UNIQUE NOT NULL,
	fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT pk_cuentas_id PRIMARY KEY (id)
);

/*************************************************************/

CREATE TABLE CLASES_TIPOS (
	id INT IDENTITY(1,1) NOT NULL,
	nombre VARCHAR(20) NOT NULL,
	CONSTRAINT pk_clases_tipos_id PRIMARY KEY (id)
);

/*************************************************************/

CREATE TABLE CLASES (
	id INT IDENTITY(1,1) NOT NULL,
	nombre VARCHAR(15) NOT NULL,
	descripcion TEXT NULL,
	id_tipo INT NOT NULL,
	CONSTRAINT pk_clases_id PRIMARY KEY (id),
	CONSTRAINT fk_clases_id_tipo FOREIGN KEY (id_tipo) REFERENCES CLASES_TIPOS (id)
);

/*************************************************************/

CREATE TABLE RAZAS (
	id INT IDENTITY(1,1) NOT NULL,
	nombre VARCHAR(15) NOT NULL,
	descripcion TEXT NULL,
	CONSTRAINT pk_razas_id PRIMARY KEY (id)
);

/*************************************************************/

CREATE TABLE SEXOS (
	id INT IDENTITY(1,1) NOT NULL,
	nombre VARCHAR(255) UNIQUE NOT NULL,
	CONSTRAINT pk_sexo_id PRIMARY KEY (id)
);

/*************************************************************/

CREATE TABLE PERSONAJES (
	id INT IDENTITY(1,1) NOT NULL,
	id_cuenta INT NOT NULL,
	nombre VARCHAR(20) UNIQUE NOT NULL,
	id_clase INT NOT NULL,
	id_raza INT NOT NULL,
	id_sexo INT NOT NULL,
	fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT pk_personajes_id PRIMARY KEY (id),
	CONSTRAINT fk_cuenta_id FOREIGN KEY (id_cuenta) REFERENCES CUENTAS (id),
	CONSTRAINT fk_clase_id FOREIGN KEY (id_clase) REFERENCES CLASES (id),
	CONSTRAINT fk_raza_id FOREIGN KEY (id_raza) REFERENCES RAZAS (id),
	CONSTRAINT fk_sexo_id FOREIGN KEY (id_sexo) REFERENCES SEXOS (id)
);

/*************************************************************/

CREATE TABLE NIVELES (
	id INT IDENTITY(1,1) NOT NULL,
	nivel INT NOT NULL,
	experiencia_prox_nivel BIGINT NOT NULL,
	CONSTRAINT pk_niveles_id PRIMARY KEY (id)
);

/*************************************************************/

CREATE TABLE ESTADOS_PERSONAJES (
	id INT IDENTITY(1,1) NOT NULL,
	estado_personaje VARCHAR(30) UNIQUE NOT NULL,
	CONSTRAINT pk_id_estado_personaje PRIMARY KEY (id)
);

/*************************************************************/

CREATE TABLE ESTADISTICAS_PERSONAJES (
	id_personaje INT NOT NULL, 	
	id_nivel INT NOT NULL DEFAULT 1,
	experiencia_actual BIGINT NOT NULL DEFAULT 0,
	id_estado_personaje INT NOT NULL DEFAULT 1,
	personajes_matados INT NOT NULL DEFAULT 0,
	monstruos_matados INT NOT NULL DEFAULT 0,
	horas_jugadas FLOAT NOT NULL DEFAULT 0,
	CONSTRAINT pk_est_id_personaje PRIMARY KEY (id_personaje),
	CONSTRAINT fk_est_id_personaje FOREIGN KEY (id_personaje) REFERENCES PERSONAJES (id),
	CONSTRAINT fk_est_personaje_id_nivel FOREIGN KEY (id_nivel) REFERENCES NIVELES (id),
	CONSTRAINT fk_est_personaje_id_estado_personaje FOREIGN KEY (id_estado_personaje) REFERENCES ESTADOS_PERSONAJES (id)
);

/*************************************************************/

CREATE TABLE ESTADISTICAS_COMBATE_PERSONAJES (
	id_personaje INT NOT NULL,
	vida_maxima INT NOT NULL,
	mana_maxima INT NOT NULL,
	vida_actual INT NOT NULL,
	mana_actual INT NOT NULL,
	ataque INT NOT NULL,
	agilidad INT NOT NULL,
	CONSTRAINT pk_est_comb_id_personaje PRIMARY KEY (id_personaje),
	CONSTRAINT fk_est_comb_id_personaje FOREIGN KEY (id_personaje) REFERENCES PERSONAJES (id)
);

/*************************************************************/

CREATE TABLE MONSTRUOS (
	id INT IDENTITY(1,1) NOT NULL,
	nombre VARCHAR(20) NOT NULL,
	experiencia_otorgada BIGINT NOT NULL,
	vida_maxima FLOAT NOT NULL,
	ataque FLOAT NOT NULL,
	defensa FLOAT NOT NULL,
	descripcion_adicional TEXT NULL,
	tiempo_reaparicion_en_segundos INT NOT NULL DEFAULT 10,
	CONSTRAINT pk_monstruo_id PRIMARY KEY (id)
);

/*************************************************************/

CREATE TABLE MODIFICADORES_DE_CLASES (
	id_clase INT NOT NULL,
	ataque FLOAT NOT NULL,
	agilidad FLOAT NOT NULL,
	mana FLOAT NOT NULL,
	vida FLOAT NOT NULL,
	CONSTRAINT pk_mod_clase_id_clase PRIMARY KEY (id_clase),
	CONSTRAINT fk_mod_clase_id_clase FOREIGN KEY (id_clase) REFERENCES CLASES (id)
);

/*************************************************************/

CREATE TABLE MODIFICADORES_DE_RAZAS (
	id_raza INT NOT NULL,
	ataque FLOAT NOT NULL,
	agilidad FLOAT NOT NULL,
	mana FLOAT NOT NULL,
	vida FLOAT NOT NULL,
	CONSTRAINT pk_mod_raza_id_raza PRIMARY KEY (id_raza),
	CONSTRAINT fk_mod_raza_id_raza FOREIGN KEY (id_raza) REFERENCES RAZAS (id)
);


/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/************************ PROCEDURES *************************************/

CREATE PROCEDURE crearCuenta 
	@nombre_usuario VARCHAR(30),
	@contrasenia VARCHAR(30),
	@email VARCHAR(50)
AS
BEGIN
	IF EXISTS (
		SELECT 1 
		FROM CUENTAS 
		WHERE CUENTAS.nombre_usuario = @nombre_usuario
	)
	BEGIN
		RAISERROR('La cuenta ya existe.', 16, 1);
		RETURN;
	END

	IF EXISTS (
		SELECT 1
		FROM CUENTAS
		WHERE CUENTAS.email = @email
	)
	BEGIN
		RAISERROR('El email ya está en uso.', 16, 1);
		RETURN;
	END

	INSERT INTO CUENTAS (nombre_usuario, contrasenia, email) VALUES (@nombre_usuario, @contrasenia, @email);
END;


/*************************************************************/
-- Máximo de 6 personajes por cuenta.

CREATE PROCEDURE crearPersonaje
	@id_cuenta INT,
	@nombre VARCHAR(20),
	@id_clase INT,
	@id_raza INT,
	@id_sexo INT
AS
BEGIN
	BEGIN TRANSACTION;

	BEGIN TRY;
		IF NOT EXISTS (
			SELECT 1
			FROM CUENTAS
			WHERE CUENTAS.id = @id_cuenta
		)
		BEGIN
			RAISERROR('La cuenta no existe.', 16, 1);
			RETURN;
		END

		IF (
			SELECT COUNT(*)
			FROM PERSONAJES
			WHERE PERSONAJES.id_cuenta = @id_cuenta
		) >= 6
		BEGIN
			RAISERROR('Superaste el límite de 6 personajes en tu cuenta.', 16, 1);
			RETURN;
		END
		
		IF EXISTS (
			SELECT 1
			FROM PERSONAJES
			WHERE PERSONAJES.nombre = @nombre
		)
		BEGIN
			RAISERROR('El nombre del personaje ya existe.', 16, 1);
			RETURN;
		END

		IF NOT EXISTS (
			SELECT 1
			FROM CLASES
			WHERE CLASES.id = @id_clase
		)
		BEGIN
			RAISERROR('Datos inválidos!!! La clase no existe.', 16, 1);
			RETURN;
		END

		IF NOT EXISTS (
			SELECT 1
			FROM RAZAS
			WHERE RAZAS.id = @id_raza
		)
		BEGIN
			RAISERROR('Datos inválidos!!! La raza no existe.', 16, 1);
			RETURN;
		END

		IF NOT EXISTS (
			SELECT 1
			FROM SEXOS
			WHERE SEXOS.id = @id_sexo
		)
		BEGIN
			RAISERROR('Datos inválidos!!! El sexo no existe.', 16, 1);
			RETURN;
		END

		/***************************************************/

		INSERT INTO PERSONAJES (id_cuenta, nombre, id_clase, id_raza, id_sexo) 
		VALUES (@id_cuenta, @nombre, @id_clase, @id_raza, @id_sexo);

		/***************************************************/

		-- Obtener modificadores de clase
        DECLARE @mod_ataque_clase FLOAT; 
		DECLARE @mod_agilidad_clase FLOAT; 
		DECLARE @mod_mana_clase FLOAT; 
		DECLARE @mod_vida_clase FLOAT;

        SELECT @mod_ataque_clase = ataque, 
			   @mod_agilidad_clase = agilidad, 
			   @mod_mana_clase = mana, 
			   @mod_vida_clase = vida
        FROM MODIFICADORES_DE_CLASES
        WHERE id_clase = @id_clase;


		-- Obtener modificadores de raza
        DECLARE @mod_ataque_raza FLOAT;
		DECLARE @mod_agilidad_raza FLOAT;
		DECLARE @mod_mana_raza FLOAT;
		DECLARE @mod_vida_raza FLOAT;

        SELECT @mod_ataque_raza = ataque, 
		       @mod_agilidad_raza = agilidad, 
			   @mod_mana_raza = mana, 
			   @mod_vida_raza = vida
        FROM MODIFICADORES_DE_RAZAS
        WHERE id_raza = @id_raza;


		 -- Calcular los atributos finales
        DECLARE @ataque_final FLOAT;
		DECLARE @mana_final FLOAT;        
        SET @ataque_final = @mod_ataque_clase * @mod_ataque_raza;
        SET @mana_final = @mod_mana_clase * @mod_mana_raza;


        -- Obtener el ID del personaje recién creado
        DECLARE @PersonajeID INT;
        SET @PersonajeID = SCOPE_IDENTITY();


        -- Insertar estadísticas del personaje
		INSERT INTO ESTADISTICAS_PERSONAJES (id_personaje)
		VALUES (@PersonajeID);


        -- Insertar estadísticas de combate
        INSERT INTO ESTADISTICAS_COMBATE_PERSONAJES (id_personaje, vida_maxima, mana_maxima, vida_actual, mana_actual, ataque, agilidad)
        VALUES (@PersonajeID, @mod_vida_raza, @mana_final, @mod_vida_raza, @mana_final, @ataque_final, @mod_agilidad_raza);

		/***************************************************/

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);  -- Lanzar el error
    END CATCH
END;


/*************************************************************/

CREATE PROCEDURE estadisticasId
@id_personaje INT
AS
BEGIN
	SELECT PERSONAJES.nombre AS 'Personaje', 
	       CLASES.nombre AS 'Clase', 
		   RAZAS.nombre AS 'Raza', 
		   SEXOS.nombre AS 'Sexo', 
		   NIVELES.nivel AS 'Nivel', 
		   ESTADISTICAS_PERSONAJES.experiencia_actual AS 'Experiencia actual', 
		   (ESTADISTICAS_PERSONAJES.experiencia_actual * 100 / NIVELES.experiencia_prox_nivel) AS 'Experiencia actual %',
		   CONCAT(ESTADISTICAS_COMBATE_PERSONAJES.vida_actual,'/',ESTADISTICAS_COMBATE_PERSONAJES.vida_maxima) AS 'Vida',
		   CONCAT(ESTADISTICAS_COMBATE_PERSONAJES.mana_actual,'/',ESTADISTICAS_COMBATE_PERSONAJES.mana_maxima) AS 'Mana',
		   ESTADISTICAS_PERSONAJES.personajes_matados AS 'Personajes matados',
		   ESTADISTICAS_PERSONAJES.monstruos_matados AS 'Monstruos matados',
		   ESTADISTICAS_PERSONAJES.horas_jugadas AS 'Horas jugadas',
		   ESTADOS_PERSONAJES.estado_personaje AS 'Estado',
		   PERSONAJES.fecha_creacion AS 'Fecha de creacion'
	FROM PERSONAJES
	INNER JOIN CLASES ON PERSONAJES.id_clase = CLASES.id
	INNER JOIN RAZAS ON PERSONAJES.id_raza = RAZAS.id
	INNER JOIN SEXOS ON PERSONAJES.id_sexo = SEXOS.id
	INNER JOIN ESTADISTICAS_COMBATE_PERSONAJES ON PERSONAJES.id = ESTADISTICAS_COMBATE_PERSONAJES.id_personaje
	INNER JOIN ESTADISTICAS_PERSONAJES ON PERSONAJES.id = ESTADISTICAS_PERSONAJES.id_personaje
	INNER JOIN NIVELES ON ESTADISTICAS_PERSONAJES.id_nivel = NIVELES.id
	INNER JOIN ESTADOS_PERSONAJES ON ESTADISTICAS_PERSONAJES.id_estado_personaje = ESTADOS_PERSONAJES.id
	WHERE PERSONAJES.id = @id_personaje;
END;


/*************************************************************/

CREATE PROCEDURE estadisticasNombre
@nombre_personaje VARCHAR(20)
AS
BEGIN
	SELECT PERSONAJES.nombre AS 'Personaje', 
	       CLASES.nombre AS 'Clase', 
		   RAZAS.nombre AS 'Raza', 
		   SEXOS.nombre AS 'Sexo', 
		   NIVELES.nivel AS 'Nivel', 
		   ESTADISTICAS_PERSONAJES.experiencia_actual AS 'Experiencia actual', 
		   (ESTADISTICAS_PERSONAJES.experiencia_actual * 100 / NIVELES.experiencia_prox_nivel) AS 'Experiencia actual %',
		   CONCAT(ESTADISTICAS_COMBATE_PERSONAJES.vida_actual,'/',ESTADISTICAS_COMBATE_PERSONAJES.vida_maxima) AS 'Vida',
		   CONCAT(ESTADISTICAS_COMBATE_PERSONAJES.mana_actual,'/',ESTADISTICAS_COMBATE_PERSONAJES.mana_maxima) AS 'Mana',
		   ESTADISTICAS_PERSONAJES.personajes_matados AS 'Personajes matados',
		   ESTADISTICAS_PERSONAJES.monstruos_matados AS 'Monstruos matados',
		   ESTADISTICAS_PERSONAJES.horas_jugadas AS 'Horas jugadas',
		   ESTADOS_PERSONAJES.estado_personaje AS 'Estado',
		   PERSONAJES.fecha_creacion AS 'Fecha de creacion'
	FROM PERSONAJES
	INNER JOIN CLASES ON PERSONAJES.id_clase = CLASES.id
	INNER JOIN RAZAS ON PERSONAJES.id_raza = RAZAS.id
	INNER JOIN SEXOS ON PERSONAJES.id_sexo = SEXOS.id
	INNER JOIN ESTADISTICAS_COMBATE_PERSONAJES ON PERSONAJES.id = ESTADISTICAS_COMBATE_PERSONAJES.id_personaje
	INNER JOIN ESTADISTICAS_PERSONAJES ON PERSONAJES.id = ESTADISTICAS_PERSONAJES.id_personaje
	INNER JOIN NIVELES ON ESTADISTICAS_PERSONAJES.id_nivel = NIVELES.id
	INNER JOIN ESTADOS_PERSONAJES ON ESTADISTICAS_PERSONAJES.id_estado_personaje = ESTADOS_PERSONAJES.id
	WHERE PERSONAJES.nombre = @nombre_personaje;
END;


/*************************************************************/

CREATE PROCEDURE actualizarPersonajes
    @id_personaje INT,
    @experiencia_ganada BIGINT,
    @monstruos_matados INT,
    @personajes_matados INT,
    @horas_jugadas FLOAT
AS
BEGIN
	DECLARE @nivel_actual INT;

	SELECT @nivel_actual = NIVELES.nivel
	FROM ESTADISTICAS_PERSONAJES
	INNER JOIN NIVELES ON ESTADISTICAS_PERSONAJES.id_nivel = NIVELES.id
	WHERE ESTADISTICAS_PERSONAJES.id_personaje = @id_personaje

	IF @nivel_actual >= 47
	BEGIN
		SET @experiencia_ganada = 0;
	END

    -- Actualizamos la experiencia, monstruos matados y personajes matados
    UPDATE ESTADISTICAS_PERSONAJES
    SET experiencia_actual = experiencia_actual + @experiencia_ganada,
        monstruos_matados = monstruos_matados + @monstruos_matados,
        personajes_matados = personajes_matados + @personajes_matados,
        horas_jugadas = horas_jugadas + @horas_jugadas
    WHERE id_personaje = @id_personaje;
END;


/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/************************TRIGGERS*************************************/

CREATE TRIGGER trg_subirNivel
ON ESTADISTICAS_PERSONAJES
AFTER UPDATE
AS
BEGIN
    DECLARE @id_personaje INT;
    DECLARE @experiencia_actual BIGINT;
	DECLARE @id_nivel_actual INT;
    DECLARE @nivel_actual INT;
    DECLARE @experiencia_prox_nivel BIGINT;
    DECLARE @id_clase INT;
    DECLARE @id_raza INT;

    DECLARE @nuevos_niveles INT;
    DECLARE @mod_ataque FLOAT;
    DECLARE @mod_agilidad FLOAT;
    DECLARE @mod_mana FLOAT;
    DECLARE @mod_vida FLOAT;
	
    -- Obtenemos el ID del personaje y la experiencia actual de la tabla INSERTED
    SELECT @id_personaje = i.id_personaje,
           @experiencia_actual = i.experiencia_actual,
           @id_nivel_actual = i.id_nivel
    FROM INSERTED AS i;

	-- Obtenemos nivel actual a partir del id_nivel_actual
	SELECT @nivel_actual = NIVELES.nivel
	FROM NIVELES
	WHERE NIVELES.id = @id_nivel_actual;

	IF @nivel_actual < 47
	BEGIN
		-- Inicializamos el contador de nuevos niveles
		SET @nuevos_niveles = 0;

		-- Calcula la subida de niveles segun la experiencia requerida por nivel y la experiencia insertada.
		WHILE @experiencia_actual >= (
		        SELECT experiencia_prox_nivel
		        FROM NIVELES
		        WHERE nivel = @nivel_actual
		    )
		BEGIN
		    -- Aumentamos el contador de niveles
		    SET @nuevos_niveles = @nuevos_niveles + 1;

		    -- Restamos la experiencia necesaria para el siguiente nivel
			IF @nivel_actual = 47
			BEGIN
				SET @experiencia_actual = 0;
			END
			ELSE
			BEGIN
				SET @experiencia_actual = @experiencia_actual - (
				    SELECT experiencia_prox_nivel
				    FROM NIVELES
				    WHERE nivel = @nivel_actual
				);
			END

		    -- Aumentamos el nivel del personaje
		    SET @nivel_actual = @nivel_actual + 1;

		    -- Limitamos el nivel máximo a 47
		    IF @nivel_actual > 47
		    BEGIN
		        SET @nivel_actual = 47;
		        BREAK; -- Salimos del bucle si alcanzamos el nivel máximo
		    END
		END

		-- Actualizamos el nivel final y la experiencia restante
		UPDATE ESTADISTICAS_PERSONAJES
		SET id_nivel = @nivel_actual,
		    experiencia_actual = @experiencia_actual
		WHERE id_personaje = @id_personaje;

		-- Obtenemos el ID de la clase y raza del personaje
		SELECT @id_clase = p.id_clase, 
		       @id_raza = p.id_raza
		FROM PERSONAJES p
		WHERE p.id = @id_personaje;

		-- Obtenemos los modificadores de la clase
		SELECT @mod_ataque = mc.ataque,
		       @mod_agilidad = mc.agilidad,
		       @mod_mana = mc.mana,
		       @mod_vida = mc.vida
		FROM MODIFICADORES_DE_CLASES mc
		WHERE mc.id_clase = @id_clase;

		-- Obtenemos los modificadores de la raza
		SELECT @mod_ataque = @mod_ataque * mr.ataque,
		       @mod_agilidad = @mod_agilidad * mr.agilidad,
		       @mod_mana = @mod_mana * mr.mana,
		       @mod_vida = @mod_vida * mr.vida
		FROM MODIFICADORES_DE_RAZAS mr
		WHERE mr.id_raza = @id_raza;

		-- Actualizamos las estadísticas de combate del personaje sumando los modificadores
		UPDATE ESTADISTICAS_COMBATE_PERSONAJES
		SET ataque = vida_actual + (@mod_ataque * @nuevos_niveles),
		    agilidad = agilidad + (@mod_agilidad * @nuevos_niveles),
		    mana_maxima = mana_maxima + (@mod_mana * @nuevos_niveles),
		    vida_maxima = vida_maxima + (@mod_vida * @nuevos_niveles),
		    vida_actual = vida_maxima + (@mod_vida * @nuevos_niveles), -- Restauramos vida al máximo tras subir de nivel
		    mana_actual = mana_maxima
		WHERE id_personaje = @id_personaje;
	END
END;

/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/**************************VIEW***********************************/

--Listado de personajes con sus clases y razas.
CREATE VIEW v_lista_personajes
AS
SELECT PERSONAJES.id, PERSONAJES.nombre, clases.nombre AS 'clase', RAZAS.nombre as 'raza'
FROM PERSONAJES
INNER JOIN CLASES ON PERSONAJES.id_clase = CLASES.id
INNER JOIN RAZAS ON PERSONAJES.id_raza = RAZAS.id;

/*************************************************************/

--Cantidad de personajes segun su clase.
CREATE VIEW v_cantidad_personajes_por_clase
AS
SELECT CLASES.nombre, count(PERSONAJES.id) as 'cantidad'
FROM PERSONAJES
INNER JOIN CLASES ON PERSONAJES.id_clase = CLASES.id
GROUP BY CLASES.nombre, PERSONAJES.id_clase;

/*************************************************************/

--Cuenta + lista personajes por cuenta.
CREATE VIEW v_personajes_por_cuenta
AS
SELECT CUENTAS.id, CUENTAS.nombre_usuario, STRING_AGG(PERSONAJES.nombre, ',') AS lista_personajes
FROM CUENTAS
INNER JOIN PERSONAJES ON CUENTAS.id = PERSONAJES.id_cuenta
GROUP BY CUENTAS.id, CUENTAS.nombre_usuario;


/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************INSERTS Y EXECS************************************/

INSERT INTO CLASES_TIPOS (nombre) VALUES ('Mágica');
INSERT INTO CLASES_TIPOS (nombre) VALUES ('No mágica');
INSERT INTO CLASES_TIPOS (nombre) VALUES ('Semi mágica');

/*************************************************************/

INSERT INTO CLASES (nombre, descripcion, id_tipo) VALUES ('Mago', 'La clase más débil y con menos agilidad, se basa puramente en la magia.', 1);
INSERT INTO CLASES (nombre, descripcion, id_tipo) VALUES ('Clerigo', 'Una clase que tiene su buena parte de magia y de ataque físico pero no se destaca en nada especial.', 3);
INSERT INTO CLASES (nombre, descripcion, id_tipo) VALUES ('Bardo', 'Clase parecida al Clérigo pero ésta tiene más inclinación por la magia.', 1);
INSERT INTO CLASES (nombre, descripcion, id_tipo) VALUES ('Asesino', 'Clase experta en el uso de la habilidad Apuñalar, con un buen ataque físico y mágico.', 3);
INSERT INTO CLASES (nombre, descripcion, id_tipo) VALUES ('Druida', 'Clase experta en el uso de la habilidad Domar.', 1);
INSERT INTO CLASES (nombre, descripcion, id_tipo) VALUES ('Paladin', 'Clase experta en usar armas y armaduras, tienen un muy buen ataque físico y un buen ataque mágico.', 3);
INSERT INTO CLASES (nombre, descripcion, id_tipo) VALUES ('Guerrero', 'Clase experta en el uso de las armas cuerpo a cuerpo y a distancia.', 2);
INSERT INTO CLASES (nombre, descripcion, id_tipo) VALUES ('Cazador', 'Clase experta en usar ataques a distancia con gran poder', 2);

/*************************************************************/

INSERT INTO RAZAS (nombre, descripcion) VALUES ('Humano', 'Suelen ser la raza predominante en Argentum, comunmente de tez blanca o caucásica. Sus atributos principales son la fuerza, agilidad y constitución, pero no se destacan por ninguna de ella, sino más bien, mantienen un buen balance.');
INSERT INTO RAZAS (nombre, descripcion) VALUES ('Elfo', 'Son seres de gran belleza. Largos cabellos y orejas puntiagudas los caracterizan. La agilidad, es el rasgo más sobresaliente de esta raza, aunque también, se destacan en menor medida por su inteligencia y su carisma.');
INSERT INTO RAZAS (nombre, descripcion) VALUES ('Elfo oscuro', 'De largos cabellos, conservan las puntiagudas orejas de los elfos comunes, pero su tez puede tomar tonos del gris al negro y el verde oscuro. Poseen una inteligencia semejante a la de los elfos comunes, pero son más fuertes físicamente que éstos y que los humanos a su vez, aunque no tanto como los enanos. La agilidad, es otra de sus carácteristicas principales. Al ser seres poco agradables a la vista, tienen la peor bonificación de carisma entre las razas.');
INSERT INTO RAZAS (nombre, descripcion) VALUES ('Enano', 'Seres de poca altura, contextura robusta, largas barbas y cortos cabellos. En cuanto a su tez, es generalmente caucásica. Debido a su contextura física, es la raza más fuerte y resistente (es decir, de excelente constitución), pero esto los convierte también en la clase menos ágil y su carisma se ve seriamente afectado por su tosco aspecto. A su vez, la tosudez los convierte en la clase menos inteligente.');
INSERT INTO RAZAS (nombre, descripcion) VALUES ('Gnomo', 'Al igual que los enanos, son seres de poca altura, aunque su contextura física es más pequeña y menos robusta. De tez caucásica y largos cabellos los gnomos suelen ser débiles, por lo que tienen el peor bonificador de constitución, pero de una notable agilidad, casi tan buena como la de los elfos. Esta clase es la más inteligente de las tierras.');

/*************************************************************/

INSERT INTO SEXOS (nombre) VALUES ('Hombre');
INSERT INTO SEXOS (nombre) VALUES ('Mujer');

/*************************************************************/

INSERT INTO NIVELES (nivel, experiencia_prox_nivel) VALUES (1, 300);
INSERT INTO NIVELES (nivel, experiencia_prox_nivel) VALUES (2, 450);
INSERT INTO NIVELES (nivel, experiencia_prox_nivel) VALUES (3, 675);
INSERT INTO NIVELES (nivel, experiencia_prox_nivel) VALUES (4, 1012);
INSERT INTO NIVELES (nivel, experiencia_prox_nivel) VALUES (5, 1518);
INSERT INTO NIVELES (nivel, experiencia_prox_nivel) VALUES (6, 2277);
INSERT INTO NIVELES (nivel, experiencia_prox_nivel) VALUES (7, 3416);
INSERT INTO NIVELES (nivel, experiencia_prox_nivel) VALUES (8, 5124);
INSERT INTO NIVELES (nivel, experiencia_prox_nivel) VALUES (9, 7886);
INSERT INTO NIVELES (nivel, experiencia_prox_nivel) VALUES (10, 11529);
INSERT INTO NIVELES (nivel, experiencia_prox_nivel) VALUES (11, 14988);
INSERT INTO NIVELES (nivel, experiencia_prox_nivel) VALUES (12, 19484);
INSERT INTO NIVELES (nivel, experiencia_prox_nivel) VALUES (13, 25329);
INSERT INTO NIVELES (nivel, experiencia_prox_nivel) VALUES (14, 32928);
INSERT INTO NIVELES (nivel, experiencia_prox_nivel) VALUES (15, 42806);
INSERT INTO NIVELES (nivel, experiencia_prox_nivel) VALUES (16, 55648);
INSERT INTO NIVELES (nivel, experiencia_prox_nivel) VALUES (17, 72342);
INSERT INTO NIVELES (nivel, experiencia_prox_nivel) VALUES (18, 94045);
INSERT INTO NIVELES (nivel, experiencia_prox_nivel) VALUES (19, 122259);
INSERT INTO NIVELES (nivel, experiencia_prox_nivel) VALUES (20, 158937);
INSERT INTO NIVELES (nivel, experiencia_prox_nivel) VALUES (21, 206618);
INSERT INTO NIVELES (nivel, experiencia_prox_nivel) VALUES (22, 268603);
INSERT INTO NIVELES (nivel, experiencia_prox_nivel) VALUES (23, 349184);
INSERT INTO NIVELES (nivel, experiencia_prox_nivel) VALUES (24, 453939);
INSERT INTO NIVELES (nivel, experiencia_prox_nivel) VALUES (25, 544727);
INSERT INTO NIVELES (nivel, experiencia_prox_nivel) VALUES (26, 667632);
INSERT INTO NIVELES (nivel, experiencia_prox_nivel) VALUES (27, 784406);
INSERT INTO NIVELES (nivel, experiencia_prox_nivel) VALUES (28, 941287);
INSERT INTO NIVELES (nivel, experiencia_prox_nivel) VALUES (29, 1129544);
INSERT INTO NIVELES (nivel, experiencia_prox_nivel) VALUES (30, 1355453);
INSERT INTO NIVELES (nivel, experiencia_prox_nivel) VALUES (31, 1626544);
INSERT INTO NIVELES (nivel, experiencia_prox_nivel) VALUES (32, 1951853);
INSERT INTO NIVELES (nivel, experiencia_prox_nivel) VALUES (33, 2342224);
INSERT INTO NIVELES (nivel, experiencia_prox_nivel) VALUES (34, 3372803);
INSERT INTO NIVELES (nivel, experiencia_prox_nivel) VALUES (35, 4047364);
INSERT INTO NIVELES (nivel, experiencia_prox_nivel) VALUES (36, 5828204);
INSERT INTO NIVELES (nivel, experiencia_prox_nivel) VALUES (37, 6993845);
INSERT INTO NIVELES (nivel, experiencia_prox_nivel) VALUES (38, 8392614);
INSERT INTO NIVELES (nivel, experiencia_prox_nivel) VALUES (39, 10071137);
INSERT INTO NIVELES (nivel, experiencia_prox_nivel) VALUES (40, 120853640);
INSERT INTO NIVELES (nivel, experiencia_prox_nivel) VALUES (41, 145024370);
INSERT INTO NIVELES (nivel, experiencia_prox_nivel) VALUES (42, 174029240);
INSERT INTO NIVELES (nivel, experiencia_prox_nivel) VALUES (43, 208835090);
INSERT INTO NIVELES (nivel, experiencia_prox_nivel) VALUES (44, 417670180);
INSERT INTO NIVELES (nivel, experiencia_prox_nivel) VALUES (45, 835340360);
INSERT INTO NIVELES (nivel, experiencia_prox_nivel) VALUES (46, 1670680720);
INSERT INTO NIVELES (nivel, experiencia_prox_nivel) VALUES (47, 1670680720);

/*************************************************************/

INSERT INTO ESTADOS_PERSONAJES (estado_personaje) VALUES ('Desconectado');
INSERT INTO ESTADOS_PERSONAJES (estado_personaje) VALUES ('Conectado');

/*************************************************************/

INSERT INTO MONSTRUOS (nombre, experiencia_otorgada, vida_maxima, ataque, defensa) VALUES ('Lobo', 100, 75, 18, 8);
INSERT INTO MONSTRUOS (nombre, experiencia_otorgada, vida_maxima, ataque, defensa) VALUES ('Arania gigante', 1450, 1000, 100, 70);
INSERT INTO MONSTRUOS (nombre, experiencia_otorgada, vida_maxima, ataque, defensa) VALUES ('Medusa', 12250, 6500, 170, 20);
INSERT INTO MONSTRUOS (nombre, experiencia_otorgada, vida_maxima, ataque, defensa) VALUES ('Gran dragon rojo', 265000, 200000, 100, 0);

/*************************************************************/

INSERT INTO MODIFICADORES_DE_CLASES (id_clase, ataque, agilidad, mana, vida) VALUES (1, 0.50, 0.20, 8.33, 7.50); --mago
INSERT INTO MODIFICADORES_DE_CLASES (id_clase, ataque, agilidad, mana, vida) VALUES (2, 0.85, 0.80, 4.50, 8.50); --clerigo
INSERT INTO MODIFICADORES_DE_CLASES (id_clase, ataque, agilidad, mana, vida) VALUES (3, 0.75, 1.20, 4.50, 8.50); --bardo
INSERT INTO MODIFICADORES_DE_CLASES (id_clase, ataque, agilidad, mana, vida) VALUES (4, 0.95, 0.95, 2.50, 9.00); --asesino
INSERT INTO MODIFICADORES_DE_CLASES (id_clase, ataque, agilidad, mana, vida) VALUES (5, 0.65, 0.65, 4.50, 8.50); --druida
INSERT INTO MODIFICADORES_DE_CLASES (id_clase, ataque, agilidad, mana, vida) VALUES (6, 0.95, 0.85, 2.50, 10.00); --paladin
INSERT INTO MODIFICADORES_DE_CLASES (id_clase, ataque, agilidad, mana, vida) VALUES (7, 1.10, 1.00, 0.00, 10.50); --guerrero
INSERT INTO MODIFICADORES_DE_CLASES (id_clase, ataque, agilidad, mana, vida) VALUES (8, 0.80, 0.90, 0.00, 10.00); --cazador

/*************************************************************/

INSERT INTO MODIFICADORES_DE_RAZAS (id_raza, ataque, agilidad, mana, vida) VALUES (1, 19, 19, 18, 20); --humano
INSERT INTO MODIFICADORES_DE_RAZAS (id_raza, ataque, agilidad, mana, vida) VALUES (2, 18, 20, 20, 19); --elfo
INSERT INTO MODIFICADORES_DE_RAZAS (id_raza, ataque, agilidad, mana, vida) VALUES (3, 20, 19, 19, 19); --elfo oscuro
INSERT INTO MODIFICADORES_DE_RAZAS (id_raza, ataque, agilidad, mana, vida) VALUES (4, 21, 18, 15, 21); --enano
INSERT INTO MODIFICADORES_DE_RAZAS (id_raza, ataque, agilidad, mana, vida) VALUES (5, 16, 21, 22, 18); --gnomo

/*************************************************************/

EXEC crearCuenta @nombre_usuario = 'Shearow', @contrasenia = '123123', @email = 'asdasd@hotmail.com';
EXEC crearCuenta @nombre_usuario = 'Curien', @contrasenia = '321321', @email = 'curien@hotmail.com';
EXEC crearCuenta @nombre_usuario = 'Tomas', @contrasenia = '666', @email = 'tomas@gmail.com';

/*************************************************************/

EXEC crearPersonaje @id_cuenta = 1, @nombre = 'Saveth', @id_clase = 5, @id_raza = 2, @id_sexo = 2;
EXEC crearPersonaje @id_cuenta = 1, @nombre = 'Clemt', @id_clase = 6, @id_raza = 3, @id_sexo = 1;
EXEC crearPersonaje @id_cuenta = 1, @nombre = 'Claph', @id_clase = 2, @id_raza = 3, @id_sexo = 1;
EXEC crearPersonaje @id_cuenta = 1, @nombre = 'Maredy', @id_clase = 1, @id_raza = 1, @id_sexo = 2;
EXEC crearPersonaje @id_cuenta = 1, @nombre = 'MarcosTurro', @id_clase = 1, @id_raza = 2, @id_sexo = 1;
EXEC crearPersonaje @id_cuenta = 1, @nombre = 'Netto', @id_clase = 3, @id_raza = 1, @id_sexo = 1;
EXEC crearPersonaje @id_cuenta = 2, @nombre = 'Curien', @id_clase = 4, @id_raza = 1, @id_sexo = 1;
EXEC crearPersonaje @id_cuenta = 3, @nombre = 'Tomisho', @id_clase = 1, @id_raza = 2, @id_sexo = 1;

/*************************************************************/

EXEC estadisticasId @id_personaje = 2;
EXEC estadisticasNombre @nombre_personaje = 'Saveth';

/*************************************************************/

EXEC actualizarPersonajes @id_personaje = 1, @experiencia_ganada = 300, @monstruos_matados = 50, @personajes_matados = 20, @horas_jugadas = 5;
EXEC actualizarPersonajes @id_personaje = 5, @experiencia_ganada = 300000, @monstruos_matados = 50, @personajes_matados = 20, @horas_jugadas = 5;

/********************************************************************/