#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QtGui/QMainWindow>
#include <QtGui/QWidget>
#include <QDeclarativeEngine>
#include <QDeclarativeView>
#include <QDeclarativeComponent>
#include <QDeclarativeContext>
#include <QUrl>
#include <QFile>
#include <QtConcurrentRun>

#include "configuration.h"
#include "panoramaui.h"
#include "applicationmodel.h"
#include "appaccumulator.h"
#include "constants.h"
#include "setting.h"

/**
 * A MainWindow that is capable of displaying the Panorama's GUI
 */
class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    /** Constructs a new MainWindow instance */
    MainWindow(QWidget *parent = 0);

signals:
    /** A new UI file should be loaded */
    void uiChanged(const QString &uiFile);

public slots:
    /** Load the specified UI file */
    void loadUIFile(const QString &file);

    /** Change to the UI in the specified directory */
    void switchToUI(const QString &uiDir, const QString &uiName);

private slots:
    void continueLoadingUI();

private:
    void printError(const QDeclarativeComponent *obj) const;

    void loadApps();

    volatile bool appsLoaded;
    QDeclarativeEngine _engine;
    QDeclarativeView _canvas;
    QDeclarativeComponent *_component;
    PanoramaUI *_ui;
    Configuration _config;
    ApplicationModel _model;
    AppAccumulator _accumulator;
};

#endif // MAINWINDOW_H
