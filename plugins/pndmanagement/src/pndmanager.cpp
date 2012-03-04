#include "pndmanager.h"
#include "syncworker.h"
#include "downloadworker.h"

#include <QDebug>

QString const PNDManager::REPOSITORY_URL("http://repo.openpandora.org/includes/get_data.php");
//QString const PNDManager::REPOSITORY_URL("http://ewmedia/repo.json");

PNDManager::PNDManager(QObject* parent) : QObject(parent), 
  context(new QPndman::Context(this)),
  repository(new QPndman::Repository(context, REPOSITORY_URL)),
  localRepository(new QPndman::LocalRepository(context)),
  tmpDevice(new QPndman::Device(context, "/tmp")),
  packages(), packagesById(), devices()
{
  repository->loadFrom(tmpDevice);
  localRepository->loadFrom(tmpDevice);
  devices << tmpDevice;
  devices.append(QPndman::Device::detectDevices(context));
}

PNDManager::~PNDManager()
{
  tmpDevice->saveRepositories();
}

QList< QPndman::Device* > PNDManager::getDevices()
{
  return devices;
}

QList< Package* > PNDManager::getPackages()
{
  return packages;
}

QList<QObject*> PNDManager::getPackagesQObject()
{
  QList<QObject*> result;
  foreach(Package* p, packages)
  {
    result << p;
  }
  return result;
}

QList<QObject*> PNDManager::getPackagesFromCategory(QString categoryFilter)
{
  QRegExp re(categoryFilter);
  QList<QObject*> result;
  foreach(Package* p, packages)
  {
    foreach(QPndman::Category category, p->getCategories())
    {
      if(re.exactMatch(category.getMain()))
      {
        result << p;
        break;
      }
    }

  }
  return result;
}

PNDListModel* PNDManager::getList()
{
  return new PNDListModel(this);
}

void PNDManager::crawl()
{
  qDebug() << "PNDManager::crawl";
  emit crawling();
  foreach(QPndman::Device* device, devices)
  {
    device->crawl();
  }
  repository->update();
  localRepository->update();
  updatePackages();
  emit crawlDone();
}

void PNDManager::sync()
{
  qDebug() << "PNDManager::sync";
  QPndman::SyncHandle* handle = repository->sync();
  emit syncing(handle);
  SyncWorker* worker = new SyncWorker(handle);
  handle->setParent(worker);
  connect(worker, SIGNAL(ready(QPndman::SyncHandle*)), repository, SLOT(update()));
  connect(worker, SIGNAL(ready(QPndman::SyncHandle*)), this, SLOT(updatePackages()));
  connect(worker, SIGNAL(ready(QPndman::SyncHandle*)), this, SIGNAL(syncDone()));
  worker->start();
}

void PNDManager::updatePackages()
{
  qDebug() << "PNDManager::updatePackages";
  QList<QPndman::Package> installedPackages = localRepository->getPackages();
  QList<QPndman::Package> remotePackages = repository->getPackages();

  QMap<QString, QPndman::Package> installed;
  foreach(QPndman::Package p, installedPackages)
  {
    installed.insert(p.getId(), p);
  }

  QMap<QString, QPndman::Package> remote;
  foreach(QPndman::Package p, remotePackages)
  {
    remote.insert(p.getId(), p);
  }

  QMutableListIterator<Package*> i(packages);
  packagesById.clear();
  while(i.hasNext())
  {
    Package* p = i.next();
    bool isInInstalled = installed.contains(p->getId());
    if(isInInstalled || remote.contains(p->getId()))
    {
      p->setInstalled(isInInstalled);
      QPndman::Package package = isInInstalled ? installed.value(p->getId()) : remote.value(p->getId());
      p->updateFrom(package);
      packagesById.insert(p->getId(), p);
    }
    else
    {
      i.remove();
      delete p;
    }
  }

  foreach(QPndman::Package p, installedPackages)
  {
    if(!packagesById.contains(p.getId()))
    {
      Package* package = new Package(p, true, this);
      packagesById.insert(package->getId(), package);
      packages << package;
    }
  }

  foreach(QPndman::Package p, remotePackages)
  {
    if(!packagesById.contains(p.getId()))
    {
      Package* package = new Package(p, false, this);
      packagesById.insert(package->getId(), package);
      packages << package;
    }
  }

  emit packagesChanged(packages);
}

void PNDManager::install(Package* package, QPndman::Device* device, QPndman::InstallLocation location)
{
  qDebug() << "PNDManager::install";
  QPndman::InstallHandle* handle = device->install(*package, location);
  if(!handle)
  {
    emit(error(QString("Error installing %1").arg(package->getTitle())));
    return;
  }
  DownloadWorker* worker = new DownloadWorker(handle);
  handle->setParent(worker);
  connect(handle, SIGNAL(bytesDownloadedChanged(qint64)), package, SIGNAL(bytesDownloadedChanged(qint64)));
  connect(handle, SIGNAL(bytesToDownloadChanged(qint64)), package, SIGNAL(bytesToDownloadChanged(qint64)));
  connect(handle, SIGNAL(done()), package, SLOT(setInstalled()));
  connect(handle, SIGNAL(done()), this, SLOT(crawl()));
  worker->start();
  emit installing(package, handle);
}

void PNDManager::remove(Package* package)
{
  qDebug() << "PNDManager::remove";
  foreach(QPndman::Device* device, devices)
  {
    if(device->getDevice() == package->getDevice())
    {
      if(device->remove(*package))
      {
        package->setBytesDownloaded(0);
        package->setInstalled(false);
        crawl();
      }
      else
      {
        emit error("Error removing pnd");
      }
    }
  }
}

void PNDManager::upgrade(Package* package)
{
  qDebug() << "PNDManager::upgrade";
  QPndman::UpgradeHandle* handle = package->upgrade();
  if(!handle)
  {
    emit(error(QString("Error upgrading %1").arg(package->getTitle())));
    return;
  }
  DownloadWorker* worker = new DownloadWorker(handle);
  handle->setParent(worker);
  connect(handle, SIGNAL(bytesDownloadedChanged(qint64)), package, SIGNAL(bytesDownloadedChanged(qint64)));
  connect(handle, SIGNAL(bytesToDownloadChanged(qint64)), package, SIGNAL(bytesToDownloadChanged(qint64)));
  connect(handle, SIGNAL(done()), this, SLOT(crawl()));
  worker->start();
  emit upgrading(package, handle);
}
