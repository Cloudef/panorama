import QtQuick 1.1
import Panorama.Settings 1.0
import Panorama.UI 1.0
import Panorama.PNDManagement 1.0
import Panorama.Pandora 1.0

PanoramaUI {
  id: ui
  name: "PNDManager"
  description: "PND Manager application"
  author: "B-ZaR"
  anchors.fill: parent

  Setting {
    id: showSplashScreen
    defaultValue: true
    key: "showSplashScreen"
    section: "PNDManager"
  }

  Setting {
    id: showHints
    defaultValue: true
    key: "showHints"
    section: "PNDManager"
  }

  Setting {
      id: mouseCursorVisible
      section: "PNDManager"
      key: "mouseCursorVisible"
      defaultValue: false
      onValueChanged: runtime.mouseCursorVisible = value
      Component.onCompleted: runtime.mouseCursorVisible = value
  }


  Setting {
      id: lastInstallDevice
      section: "PNDManager"
      key: "lastInstallDevice"
      defaultValue: ""
  }

  Setting {
      id: lastInstallLocation
      section: "PNDManager"
      key: "lastInstallLocation"
      defaultValue: ""
  }

  Setting {
      id: loggingVerbosity
      section: "PNDManager"
      key: "loggingVerbosity"
      defaultValue: "1"
      onValueChanged: pndManager.verbosity = value
      Component.onCompleted: pndManager.verbosity = value
  }

  function init() {
    pndManager.crawl();
  }

  Timer {
     interval: 100
     repeat: false
     running: true
     onTriggered: ui.init()
  }

  PNDManager {
    id: pndManager
    onSyncing: bottomBar.syncing = true
    onSyncDone: {
      bottomBar.syncing = false
      syncCompleteNotification.show()
    }
  }

  PNDUtils { id: pndUtils }

  Keys.onPressed: {
    if(spinner.visible || !runtime.isActiveWindow || pndManager.applicationRunning) {
      event.accepted = true;
      return
    }

    if(!Pandora.controlsActive) {
      event.accepted = true;
      if(event.key === Qt.Key_PageDown) {
        views.current.pop();
      } else if(event.key === Qt.Key_End) {
        if(splashScreen.visible) {
          splashScreen.hide();
        } else {
          views.current.current.okButton();
        }
      } else if(event.key === Qt.Key_Home) {
        if(splashScreen.visible) {
          splashScreen.dontShowAgain();
        } else {
          views.current.current.removeButton();
        }
      } else if(event.key === Qt.Key_PageUp) {
        views.current.current.installUpgradeButton();
      } else if(event.key === Qt.Key_1) {
        homeStack.activate();
      } else if(event.key === Qt.Key_2) {
        categoriesStack.activate();
      } else if(event.key === Qt.Key_3) {
        installedStack.activate();
      } else if(event.key === Qt.Key_4) {
        searchStack.activate();
      } else {
        event.accepted = false;
      }
    }

    if(event.key === Qt.Key_F1) {
      showHints.value = !showHints.value
      event.accepted = true;
    } else if(event.key === Qt.Key_Escape) {
      runtime.quit()
    }
  }

  Pandora.onPressed: {
    if(spinner.visible || !runtime.isActiveWindow || pndManager.applicationRunning) {
      event.accepted = true;
      return
    }

    event.accepted = true;
    if(event.key === Pandora.ButtonX)           views.current.pop();
    else if(event.key === Pandora.ButtonB) {
      if(splashScreen.visible) {
        splashScreen.hide();
      } else {
        views.current.current.okButton();
      }
    }
    else if(event.key === Pandora.ButtonA) {
      if(splashScreen.visible) {
        splashScreen.dontShowAgain();
      } else {
        views.current.current.removeButton();
      }
    }
    else if(event.key === Pandora.ButtonY)      views.current.current.installUpgradeButton();
    else if(event.key === Pandora.TriggerL)     views.prev();
    else if(event.key === Pandora.TriggerR)     views.next();
    else if(event.key === Pandora.ButtonStart)  bottomBar.reload();
    else if(event.key === Pandora.ButtonSelect)  views.current.current.selectButton();
  }


  Notification {
    id: syncCompleteNotification
    text: "Sync complete"
    anchors.centerIn: parent
    z: 2
  }

  SpinnerOverlay {
    id: spinner
    anchors.fill: parent
    z: 3
  }

  HelpDialog {
    id: splashScreen
    anchors.fill: parent
    z: 2
    visible: showSplashScreen.value
    onHide: visible = false
    onDontShowAgain: showSplashScreen.value = false
  }

  TopBar {
    id: topBar
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    height: 32
    title: views.getViewTitle()
    z: 1
    showCloseButton: fullscreen.value
    onCloseButtonClicked: runtime.quit()
  }

  ViewStackList {
    id: views
    anchors.top: topBar.bottom
    anchors.bottom: bottomBar.top
    anchors.left: parent.left
    anchors.right: parent.right

    ViewStack {
      id: homeStack
      onActivate: views.activate(homeStack)
      HomeView {
        pndManager: pndManager
      }
    }
    ViewStack {
      id: categoriesStack
      onActivate: views.activate(categoriesStack)
      CategoriesView {
        pndManager: pndManager
      }
    }

    ViewStack {
      id: installedStack
      onActivate: views.activate(installedStack)
      InstalledView {
        pndManager: pndManager
      }
    }

    ViewStack {
      id: searchStack
      onActivate: views.activate(searchStack)
      SearchView {
        pndManager: pndManager
      }
    }
  }

  BottomBar {
    id: bottomBar
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    height: 64
    z: 1

    backArrowVisible: !views.current.atRootView

    IconButton {
      id: homeIcon
      normalImage: "img/home_32x32.png"
      highlightImage: "img/home_white_32x32.png"
      highlight: homeStack.active
      height: parent.height
      onClicked: homeStack.activate()
    }
    IconButton {
      id: categoriesIcon
      normalImage: "img/list_32x28.png"
      highlightImage: "img/list_white_32x28.png"
      highlight: categoriesStack.active
      height: parent.height
      onClicked: categoriesStack.activate()
    }
    IconButton {
      id: installedIcon
      normalImage: "img/download_24x32.png"
      highlightImage: "img/download_white_24x32.png"
      highlight: installedStack.active
      height: parent.height
      onClicked: installedStack.activate()
    }
    IconButton {
      id: searchIcon
      normalImage: "img/magnifying_glass_32x32.png"
      highlightImage: "img/magnifying_glass_white_32x32.png"
      highlight: searchStack.active
      height: parent.height
      onClicked: searchStack.activate()
    }

    onBack: views.current.pop()
    onReload: { pndManager.sync(); }
  }
}
