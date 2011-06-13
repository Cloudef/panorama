#include "milkypackage.h"

MilkyPackage::MilkyPackage(QObject *parent) :
    QObject(parent)
{
}

QString MilkyPackage::getId() const
{
    return id;
}
QString MilkyPackage::getTitle() const
{
    return title;
}
QString MilkyPackage::getDescription() const
{
    return description;
}
QString MilkyPackage::getInfo() const
{
    return info;
}
QString MilkyPackage::getIcon() const
{
    return icon;
}
QString MilkyPackage::getUri() const
{
    return uri;
}
QString MilkyPackage::getMD5() const
{
    return md5;
}
QString MilkyPackage::getVendor() const
{
    return vendor;
}
QString MilkyPackage::getGroup() const
{
    return group;
}
QDateTime MilkyPackage::getModified() const
{
    return modified;
}

int MilkyPackage::getRating() const
{
    return rating;
}
int MilkyPackage::getSize() const
{
    return size;
}

QString MilkyPackage::getAuthorName() const
{
    return author.name;
}
QString MilkyPackage::getAuthorSite() const
{
    return author.site;
}
QString MilkyPackage::getAuthorEmail() const
{
    return author.email;
}

QString MilkyPackage::getInstalledVersionMajor() const
{
    return installedVersion.major;
}
QString MilkyPackage::getInstalledVersionMinor() const
{
    return installedVersion.minor;
}
QString MilkyPackage::getInstalledVersionRelease() const
{
    return installedVersion.release;
}
QString MilkyPackage::getInstalledVersionBuild() const
{
    return installedVersion.build;
}
QString MilkyPackage::getInstalledVersionType() const
{
    return installedVersion.type;
}

QString MilkyPackage::getCurrentVersionMajor() const
{
    return currentVersion.major;
}
QString MilkyPackage::getCurrentVersionMinor() const
{
    return currentVersion.minor;
}
QString MilkyPackage::getCurrentVersionRelease() const
{
    return currentVersion.release;
}
QString MilkyPackage::getCurrentVersionBuild() const
{
    return currentVersion.build;
}
QString MilkyPackage::getCurrentVersionType() const
{
    return currentVersion.type;
}

bool MilkyPackage::getInstalled() const
{
    return installed;
}
bool MilkyPackage::getHasUpdate() const
{
    return hasUpdate;
}
QString MilkyPackage::getInstallPath() const
{
    return installPath;
}

QString MilkyPackage::getCategories() const
{
    return categories;
}

void MilkyPackage::setId(QString newId)
{
    id = newId;
    emit idChanged(id);
}
void MilkyPackage::setTitle(QString newTitle)
{
    title = newTitle;
    emit titleChanged(title);
}
void MilkyPackage::setDescription(QString newDescription)
{
    description = newDescription;
    emit descriptionChanged(description);
}
void MilkyPackage::setInfo(QString newInfo)
{
    info = newInfo;
    emit infoChanged(info);
}
void MilkyPackage::setIcon(QString newIcon)
{
    icon = newIcon;
    emit iconChanged(icon);
}
void MilkyPackage::setUri(QString newUri)
{
    uri = newUri;
    emit uriChanged(uri);
}
void MilkyPackage::setMD5(QString newMD5)
{
    md5 = newMD5;
    emit md5Changed(md5);
}
void MilkyPackage::setVendor(QString newVendor)
{
    vendor = newVendor;
    emit vendorChanged(vendor);
}
void MilkyPackage::setGroup(QString newGroup)
{
    group = newGroup;
    emit groupChanged(group);
}
void MilkyPackage::setModified(QDateTime newModified)
{
    modified = newModified;
    emit modifiedChanged(modified);
}

void MilkyPackage::setRating(int newRating)
{
    rating = newRating;
    emit ratingChanged(rating);
}
void MilkyPackage::setSize(int newSize)
{
    size = newSize;
    emit sizeChanged(size);
}

void MilkyPackage::setAuthorName(QString newAuthorName)
{
    author.name = newAuthorName;
    emit authorNameChanged(author.name);
}
void MilkyPackage::setAuthorSite(QString newAuthorSite)
{
    author.site = newAuthorSite;
    emit authorSiteChanged(author.site);
}
void MilkyPackage::setAuthorEmail(QString newAuthorEmail)
{
    author.email = newAuthorEmail;
    emit authorEmailChanged(author.email);
}

void MilkyPackage::setInstalledVersionMajor(QString newInstalledVersionMajor)
{
    installedVersion.major = newInstalledVersionMajor;
    emit installedVersionMajorChanged(installedVersion.major);
}
void MilkyPackage::setInstalledVersionMinor(QString newInstalledVersionMinor)
{
    installedVersion.minor = newInstalledVersionMinor;
    emit installedVersionMinorChanged(installedVersion.minor);
}
void MilkyPackage::setInstalledVersionRelease(QString newInstalledVersionRelease)
{
    installedVersion.release = newInstalledVersionRelease;
    emit installedVersionReleaseChanged(installedVersion.release);
}
void MilkyPackage::setInstalledVersionBuild(QString newInstalledVersionBuild)
{
    installedVersion.build = newInstalledVersionBuild;
    emit installedVersionBuildChanged(installedVersion.build);
}
void MilkyPackage::setInstalledVersionType(QString newInstalledVersionType)
{
    installedVersion.type = newInstalledVersionType;
    emit installedVersionTypeChanged(installedVersion.type);
}

void MilkyPackage::setCurrentVersionMajor(QString newCurrentVersionMajor)
{
    currentVersion.major = newCurrentVersionMajor;
    emit currentVersionMajorChanged(currentVersion.major);
}
void MilkyPackage::setCurrentVersionMinor(QString newCurrentVersionMinor)
{
    currentVersion.minor = newCurrentVersionMinor;
    emit currentVersionMinorChanged(currentVersion.minor);
}
void MilkyPackage::setCurrentVersionRelease(QString newCurrentVersionRelease)
{
    currentVersion.release = newCurrentVersionRelease;
    emit currentVersionReleaseChanged(currentVersion.release);
}
void MilkyPackage::setCurrentVersionBuild(QString newCurrentVersionBuild)
{
    currentVersion.build = newCurrentVersionBuild;
    emit currentVersionBuildChanged(currentVersion.build);
}
void MilkyPackage::setCurrentVersionType(QString newCurrentVersionType)
{
    currentVersion.type = newCurrentVersionType;
    emit currentVersionTypeChanged(currentVersion.type);
}

void MilkyPackage::setInstalled(bool newInstalled)
{
    installed = newInstalled;
    emit installedChanged(installed);
}
void MilkyPackage::setHasUpdate(bool newHasUpdate)
{
    hasUpdate = newHasUpdate;
    emit hasUpdateChanged(hasUpdate);
}
void MilkyPackage::setInstallPath(QString newInstallPath)
{
    installPath = newInstallPath;
    emit installPathChanged(installPath);
}

void MilkyPackage::setCategories(QString newCategories)
{
    categories = newCategories;
    emit categoriesChanged(categories);
}
