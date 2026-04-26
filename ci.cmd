@echo off
setlocal

:: Den ersten Parameter (die Version) in einer Variable speichern
set "VERSION=%~1"

:: Prüfen, welche Version gewählt wurde und Pfade setzen
if "%VERSION%"=="8" (
    set "SELECTED_JAVA=%JAVA8_HOME%"
    set "SELECTED_MAVEN=%MAVEN353_HOME%"
) else if "%VERSION%"=="11" (
    set "SELECTED_JAVA=%JAVA11_HOME%"
    set "SELECTED_MAVEN=%MAVEN3912_HOME%"
) else if "%VERSION%"=="17" (
    set "SELECTED_JAVA=%JAVA17_HOME%"
    set "SELECTED_MAVEN=%MAVEN4_HOME%"
) else if "%VERSION%"=="21" (
    set "SELECTED_JAVA=%JAVA21_HOME%"
    set "SELECTED_MAVEN=%MAVEN4_HOME%"
) else if "%VERSION%"=="24" (
    set "SELECTED_JAVA=%JAVA24_HOME%"
    set "SELECTED_MAVEN=%MAVEN4_HOME%"
) else if "%VERSION%"=="25" (
    set "SELECTED_JAVA=%JAVA26_HOME%"
    set "SELECTED_MAVEN=%MAVEN4_HOME%"
) else if "%VERSION%"=="26" (
    set "SELECTED_JAVA=%JAVA26_HOME%"
    set "SELECTED_MAVEN=%MAVEN4_HOME%"
) else (
    echo Fehler: Ungueltige Version "%VERSION%". Erlaubt sind 8, 11, 17, 21, 24 oder 25.
    echo Beispiel: mvnv 8 clean install
    exit /b 1
)

:: Umgebungsvariablen für diesen Prozess anpassen
set "JAVA_HOME=%SELECTED_JAVA%"
set "MAVEN_HOME=%SELECTED_MAVEN%"
set "PATH=%SELECTED_JAVA%\bin;%SELECTED_MAVEN%\bin;%PATH%"

:: Den ersten Parameter (die Version) "wegschieben", damit nur die Maven-Befehle übrig bleiben
shift

echo [Info] Nutze Java:  %JAVA_HOME%
echo [Info] Nutze Maven: %MAVEN_HOME%
echo [Info] PATH :: %PATH%

:: Maven mit allen restlichen Parametern aufrufen
SET MAVEN_OPTS=-Xmx2048m -Xms1024m
call mvn -version
call mvn dependency:resolve dependency:resolve-sources -DskipTests=true clean install

endlocal
