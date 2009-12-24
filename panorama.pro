# panorama.pro - Project file for the Panorama source code distribution
QT += declarative
TARGET = panorama
TEMPLATE = app
INCLUDEPATH += lib/pandora-libraries/include
OTHER_FILES += root.qml
libpnd.target = lib/pandora-libraries/libpnd.a
libpnd.commands = cd \
    lib/pandora-libraries; \
    make \
    libpnd.a; \
    cd \
    ../..
QMAKE_EXTRA_TARGETS += libpnd
PRE_TARGETDEPS += lib/pandora-libraries/libpnd.a
LIBS += -Llib/pandora-libraries \
    -lpnd
SOURCES += src/main.cpp \
    src/mainwindow.cpp \
    src/configuration.cpp \
    src/panoramaui.cpp \
    src/appaccumulator.cpp \
    src/applicationmodel.cpp \
    src/application.cpp \
    src/iconfinder.cpp \
    src/desktopfile.cpp \
    src/applicationfiltermodel.cpp \
    src/applicationfiltermethods.cpp \
    src/textfile.cpp \
    src/pndscanner.cpp \
    src/pnd.cpp \
    src/sysinfo.cpp \
    src/systeminformation.cpp \
    src/setting.cpp
HEADERS += src/mainwindow.h \
    src/configuration.h \
    src/panoramaui.h \
    src/application.h \
    src/appaccumulator.h \
    src/applicationmodel.h \
    src/iconfinder.h \
    src/desktopfile.h \
    src/applicationfiltermodel.h \
    src/applicationfiltermethods.h \
    src/constants.h \
    src/textfile.h \
    src/pndscanner.h \
    src/pnd.h \
    src/sysinfo.h \
    src/systeminformation.h \
    src/setting.h
OTHER_FILES += qrc/root.qml
RESOURCES += default.qrc
