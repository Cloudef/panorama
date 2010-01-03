#include "mainwindow.h"

MainWindow::MainWindow(QWidget *parent) :
        QMainWindow(parent)
{
    //"Clear" some memory
    _component = 0;
    _ui = 0;

    //This is responsible for delaying the connection between
    //_model.dataChanged and _ui->applicationDataChanged
    //to avoid lag when the 100's of applications are loaded when starting up,
    //each application resulting in a dataChanged emission.
    appsLoaded = false;

    //Resize the window
    setFixedSize(UI_WIDTH, UI_HEIGHT);

    //Create our Canvas that we'll use later for the UI
    _canvas.setParent(this);
    _canvas.rootContext()->setContextProperty("ctxtHeight", UI_HEIGHT);
    _canvas.rootContext()->setContextProperty("ctxtWidth", UI_WIDTH);
    _canvas.setUrl(QUrl("qrc:/root.qml"));
    _canvas.setFocusPolicy(Qt::StrongFocus);
    _canvas.execute();
    this->setCentralWidget(&_canvas);

    _model.setParent(this);
    PanoramaUI::setApplicationsSource(&_model);

    //Set up the application loading/unloading procedure
    _accumulator.setParent(this);
    connect(&_accumulator, SIGNAL(appAdded(Application)),
            &_model, SLOT(addApp(Application)));
    connect(&_accumulator, SIGNAL(appRemoved(Application)),
            &_model, SLOT(removeApp(Application)));

    qRegisterMetaType<Application>("Application");

    //Load some actual applications from paths
    QtConcurrent::run(this, &MainWindow::loadApps);

    //Set up UI loading and channel quit() events from QML
    connect(&_engine, SIGNAL(quit()), this, SLOT(close()));
    connect(&_config, SIGNAL(uiChanged(QString,QString)),
            this, SLOT(switchToUI(QString,QString)));
    connect(this, SIGNAL(uiChanged(QString)), this, SLOT(loadUIFile(QString)));
    Setting::setSettingsSource(_config.generalConfig());

    if(!QFileInfo(CONFIG_FILE).exists())
    {
        QFile(":/settings.cfg").copy(CONFIG_FILE);
        //chmod 644:
        QFile(CONFIG_FILE).setPermissions(QFile::ReadOwner | QFile::WriteOwner |
                                          QFile::ReadGroup | QFile::ReadOther);
    }
    _config.loadFile(CONFIG_FILE);
}

void MainWindow::loadUIFile(const QString &file)
{
    //Clean up the old component
    if(_component)
        _component->deleteLater();

    //Create a generic component from the file
    _component = new QmlComponent(&_engine, file, this);

    //Check if the component has errors and print them
    printError(_component);

    //Try to load the component immediately, or delay the load until when it
    //has finished loading
    if(_component->isReady() && !_component->isError())
        continueLoadingUI();
    else if(!_component->isError())
        connect(_component, SIGNAL(statusChanged(QmlComponent::Status)),
                this, SLOT(continueLoadingUI()));
}

void MainWindow::printError(const QmlComponent *c) const
{
    if(c->isError())
    {
        QList<QmlError> errorList = c->errors();
        foreach (const QmlError &error, errorList)
            qWarning() << error;
        return;
    }
}

void MainWindow::continueLoadingUI()
{
    //If this is a delayed load, remove the old connection
    disconnect(_component, SIGNAL(statusChanged(QmlComponent::Status)),
               this, SLOT(continueLoadingUI()));

    //Cehck errors again (now that the component is loaded)
    printError(_component);

    //Create an instance of the component
    QObject *obj(_component->create());

    //Check errors again (now that the component is created)
    printError(_component);

    if(!_component->isError())
    {
        //Remove the old UI
        if(_ui)
            _ui->deleteLater();

        //Try to load the new component instance as our new UI
        _ui = qobject_cast<PanoramaUI *>(obj);

        //By now, we should have an UI unless the UI designer was stupid and
        //didn't put a Panorama UI in the file at all
        if(_ui)
        {
            _ui->setParentItem(_canvas.root());
            if(appsLoaded)
            {
                connect(&_model, SIGNAL(dataChanged(QModelIndex,QModelIndex)),
                        _ui, SLOT(propagateApplicationDataChange()));
            }
            _ui->indicateLoadFinished();
        }
        else
            qWarning() << "The specified UI file does not contain"
                    "a Panorama UI";
    }
}

void MainWindow::switchToUI(const QString &uiDir, const QString &uiName)
{
    emit uiChanged(QString(uiDir).append(QDir::separator()).append(uiName)
                   .append(QDir::separator()).append("ui.qml"));
}

void MainWindow::loadApps() {
    QStringList list;
    QStringList tmp;

    //XXX add whatever additional path that pndnotifyd spits .desktop files into
    tmp << QDir::root().filePath("usr") << "share" << "applications";
    list.append(tmp.join(QDir::separator()));

    tmp.clear();
    tmp << QDir::homePath() << ".local" << "share" << "applications";
    list.append(tmp.join(QDir::separator()));

    _accumulator.loadFrom(list);
    appsLoaded = true;
    if(_ui)
    {
        connect(&_model, SIGNAL(dataChanged(QModelIndex,QModelIndex)),
                _ui, SLOT(propagateApplicationDataChange()));
        _ui->propagateApplicationDataChange();
    }
}

MainWindow::~MainWindow()
{
    _config.saveFile();
}
