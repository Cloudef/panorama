#ifndef PNDFILTER_H
#define PNDFILTER_H

#include <QObject>
#include <QtDeclarative>
#include "package.h"

class PNDFilter : public QObject
{
  Q_OBJECT
  Q_PROPERTY(QDeclarativeListProperty<Package> packages READ getPackages CONSTANT)

public:
  PNDFilter(QList<Package*> packages = QList<Package*>(), QObject *parent = 0);
  PNDFilter(PNDFilter const& other);
  PNDFilter& operator=(PNDFilter const& other);

  QDeclarativeListProperty<Package> getPackages();

  Q_INVOKABLE QList<QObject*> all();
  Q_INVOKABLE PNDFilter* copy();

  Q_INVOKABLE PNDFilter* inCategory(QString categoryFilter);
  Q_INVOKABLE PNDFilter* installed(bool value = true);
  Q_INVOKABLE PNDFilter* notInstalled();
  Q_INVOKABLE PNDFilter* upgradable(bool value = true);
  Q_INVOKABLE PNDFilter* notUpgradable();
  Q_INVOKABLE PNDFilter* downloading(bool value = true);
  Q_INVOKABLE PNDFilter* notDownloading();

  Q_INVOKABLE PNDFilter* sortedByTitle();
  Q_INVOKABLE PNDFilter* sortedByLastUpdated();
  Q_INVOKABLE PNDFilter* sortedByRating();

  Q_INVOKABLE PNDFilter* titleContains(QString const& s);

private:
  QList<Package*> packages;
};

QML_DECLARE_TYPE(PNDFilter)
#endif // PNDFILTER_H
