import QtQuick 1.1

import "util.js" as Utils
import "theme.js" as Theme

View {
  property QtObject pnd
  property QtObject pndManager

  Component { id: installDialog; InstallLocationDialog {} }
  Component { id: previewPictureView; PreviewPictureView {} }

  Keys.forwardTo: textArea
  onOkButton: removeConfirmation.visible ? removeConfirmation.yes() : showPreviewPictures()
  onInstallRemoveButton: {
    if(removeConfirmation.visible)
      removeConfirmation.no()
    else if(pnd.isDownloading)
      pnd.cancelDownload()
    else if(pnd.installed)
      removeConfirmation.show()
    else
      showInstallDialog()
  }
  onUpgradeButton: if(!removeConfirmation.visible) upgrade()

  ConfirmationDialog {
    id: removeConfirmation
    message: "Remove " + pnd.title + "?"
    onYes: pnd.remove()
    z: 10
  }

  function showPreviewPictures() {
    if(pnd.previewPictures.length > 0) {
      stack.push(previewPictureView, { "previewPictures": pnd.previewPictures });
    }
  }

  function showInstallDialog() {
    if(!pnd.installed && !pnd.isDownloading) {
      stack.push(installDialog, {"pndManager": pndManager, "pnd": pnd});
    }
  }

  function upgrade() {
    console.log(pnd.installed + " " + pnd.hasUpgrade + " " + pnd.isDownloading)
    if(pnd.installed && pnd.hasUpgrade && !pnd.isDownloading) {
      pnd.upgrade();
    }
  }

  Text {
    id: titleText
    text: pnd.title
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    elide: Text.ElideRight
    horizontalAlignment: Text.Center
    font.pixelSize: 42
  }

  Row {
    id: buttons
    anchors.top: titleText.bottom
    anchors.horizontalCenter: parent.horizontalCenter
    spacing: 16
    Button {
      label: "Install"
      sublabel: Utils.prettySize(pnd.size)
      control: "game-a"
      color: Theme.colors.install
      width: 256
      height: 64
      radius: 4
      visible: !pnd.installed && !pnd.isDownloading
      onClicked: showInstallDialog()
    }
    Button {
      label: "Remove"
      sublabel: Utils.prettySize(pnd.size)
      control: "game-a"
      color: Theme.colors.remove
      width: 256
      height: 64
      radius: 4
      visible: pnd.installed && !pnd.isDownloading
      onClicked: removeConfirmation.show()
    }
    Button {
      label: "Upgrade"
      sublabel: pnd.hasUpgrade ? Utils.versionString(pnd.version) + " → " + Utils.versionString(pnd.upgradeCandidate.version) + " (" + Utils.prettySize(pnd.upgradeCandidate.size) + ")" : ""
      control: "game-y"
      color: Theme.colors.upgrade
      width: 256
      height: 64
      radius: 4
      visible: pnd.installed && pnd.hasUpgrade && !pnd.isDownloading
      onClicked: upgrade()
    }
    Column {
      width: 256
      height: 64
      visible: pnd.isDownloading
      Text {
        text: "Installing..."
        anchors.left: parent.left
        anchors.margins: 16
      }
      Rectangle {
        id: progressBarContainer
        anchors.left: parent.left
        anchors.right: parent.right
        color: "#ddd"
        radius: 24
        height: 48

        ProgressBar {
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          anchors.margins: 8
          height: 32
          radius: 16
          color: "#333"
          minimumValue: 0
          maximumValue: pnd.bytesToDownload
          value: pnd.bytesDownloaded
        }

        Image {
          source: "img/x_alt_32x32.png"
          anchors.left: parent.right
          anchors.verticalCenter: parent.verticalCenter
          anchors.margins: 16

          GuiHint {
            control: "game-a"
            anchors.left: parent.horizontalCenter
            anchors.bottom: parent.verticalCenter
            anchors.margins: 8
          }

          MouseArea {
            anchors.fill: parent
            onClicked: pnd.cancelDownload()
          }
        }
      }

      Item {
        anchors.right: parent.right
        anchors.margins: 16
        property variant progress: Utils.prettyProgress(pnd.bytesDownloaded, pnd.bytesToDownload)
        Text {
          text: parent.progress.value
          anchors.right: totalSize.left
        }
        Text {
          id: totalSize
          anchors.right: parent.right
          text: " / " + parent.progress.size + " " + parent.progress.unit
        }
      }
    }
  }

  Rectangle {
    height: 1
    color: "#eee"
    anchors.bottom: textArea.top
    anchors.left: textArea.left
    anchors.right: textArea.right
  }

  Flickable {
    id: textArea
    anchors.top: buttons.bottom
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.right: parent.horizontalCenter
    anchors.margins: 16
    contentHeight: textAreaContents.height
    contentWidth: width
    clip: true
    interactive: !removeConfirmation.visible
    NumberAnimation {
      id: scrollAnimation
      target: textArea;
      property: "contentY"
      duration: 200;
      easing.type: Easing.InOutQuad
    }

    Keys.onDownPressed: {
      if(contentHeight > height) {
        scrollAnimation.to = Math.min(contentHeight - height, contentY + height/2);
        scrollAnimation.start();
      }
    }

    Keys.onUpPressed: {
      if(contentHeight > height) {
        scrollAnimation.to = Math.max(0, contentY - height/2);
        scrollAnimation.start();
      }
    }

    Column {
      id: textAreaContents
      anchors.left: parent.left
      anchors.right: parent.right
      height: childrenRect.height
      spacing: 16

      Item {
        anchors.left: parent.left
        anchors.right: parent.right
        height: childrenRect.height

        Image {
          id: icon
          source: pnd.icon
          asynchronous: true
          smooth: true
          height: 48
          width: 48
          fillMode: Image.PreserveAspectFit
          sourceSize {
            height: 48
            width: 48
          }
          anchors.top: parent.top
          anchors.topMargin: 4
        }

        Column {
          height: childrenRect.height
          anchors.left: icon.right
          anchors.right: parent.right
          anchors.leftMargin: 8

          PackageInfoText {
            anchors.left: parent.left
            anchors.right: parent.right
            label: "Author:"
            text: pnd.author.name
          }

          PackageInfoText {
            anchors.left: parent.left
            anchors.right: parent.right
            label: "Rating:"

            function getRating() {
              var s = "";
              for(var i = 0; i < Math.ceil(pnd.rating/20); ++i) {
                s += "★";
              }
              return s;
            }

            text: pnd.rating !== 0 ? getRating() : "(not rated)"
          }

          PackageInfoText {
            anchors.left: parent.left
            anchors.right: parent.right
            label: "Last updated:"
            text: Utils.prettyLastUpdatedString(pnd.modified)
          }
        }
      }

      Text {
        text: pnd.description
        anchors.left: parent.left
        anchors.right: parent.right
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        font.pixelSize: 14
      }

      Text {
        text: "Additional information:"
        visible: additionalInformation.text != ""
        anchors.left: parent.left
        anchors.right: parent.right
        font.pixelSize: 14
        height: paintedHeight + 8
        verticalAlignment: Text.AlignBottom
        font.weight: Font.DemiBold
      }

      Text {
        id: additionalInformation
        text: pnd.info
        anchors.left: parent.left
        anchors.right: parent.right
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        font.pixelSize: 14
      }

    }
  }

  Rectangle {
    height: 1
    color: "#eee"
    anchors.top: textArea.bottom
    anchors.left: textArea.left
    anchors.right: textArea.right
  }

  Rectangle {
    height: 1
    color: "#eee"
    anchors.bottom: imageArea.top
    anchors.left: imageArea.left
    anchors.right: imageArea.right
  }

  Item {
    id: imageArea
    anchors.top: buttons.bottom
    anchors.bottom: parent.bottom
    anchors.left: parent.horizontalCenter
    anchors.right: parent.right
    anchors.margins: 16

    Image {
      id: image
      anchors.fill: parent
      anchors.bottomMargin: 4
      anchors.topMargin: 4
      source: pnd.previewPictures.length > 0 ? pnd.previewPictures[0].src : ""
      asynchronous: true
      fillMode: Image.PreserveAspectFit
      smooth: true

      Text {
          anchors.centerIn: parent
          visible: image.source == "" || image.status != Image.Ready
          text: image.source != "" ? parseInt(image.progress * 100) + "%" : "No preview"
          font.pixelSize: 24
          color: "#777"
      }

      MouseArea {
        anchors.fill: parent
        onClicked: showPreviewPictures()
      }

      Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 8
        visible: pnd.previewPictures.length > 0
        height: 32
        width: showPreviewPicturesText.paintedWidth + showPreviewPicturesIcon.width + 16
        radius: height/4
        color: Qt.rgba(0.8, 0.8, 0.8, 0.3)

        Row {
          anchors.centerIn: parent
          height: 24
          spacing: 4
          Text {
            id: showPreviewPicturesText
            text: "Show more"
            font.pixelSize: 18
            style: Text.Outline
            styleColor: "#111"
            color: "#fff"
            anchors.verticalCenter: parent.verticalCenter
          }
          GuiHint {
            id: showPreviewPicturesIcon
            control: "game-b"
            anchors.verticalCenter: parent.verticalCenter
          }
        }
      }
    }
  }

  Rectangle {
    height: 1
    color: "#eee"
    anchors.top: imageArea.bottom
    anchors.left: imageArea.left
    anchors.right: imageArea.right
  }
}

