<%@ page import="de.laser.system.SystemMessage" %>
<!doctype html>
<html>
<head>
    <meta name="layout" content="public"/>
    <title>${message(code: 'laser')}</title>
    <script>
        <g:render template="/templates/javascript/laser.js" />
        <g:render template="/templates/javascript/dict.js" />
    </script>
</head>

<body>

<div class="landingpage">
    <!-- NAVIGATION FIX -->
    <div class="ui container ">
        <div class="ui top fixed hidden inverted stackable menu la-fixed-menu">
            <div class="ui container">
                <img class="logo" alt="Logo Laser" src="${resource(dir: 'images', file: 'laser.svg')}"/>
                <a href="https://wiki1.hbz-nrw.de/display/LAS/Projekthintergrund" class="item" target="_blank">${message(code: 'landingpage.menu.about')}</a>
                <a class="item" href="https://wiki1.hbz-nrw.de/display/LAS/Startseite" target="_blank">Wiki</a>

                <div class="right item">
                    <g:link controller="home" action="index" class="ui button blue">
                        ${message(code: 'landingpage.login')}
                    </g:link>
                </div>
            </div>
        </div>
    </div>

    <!--Page Contents-->
    <div class="pusher">
        <div class="ui inverted stackable menu la-top-menu">
            <div class="ui container">
                <img class="logo" alt="Logo Laser" src="${resource(dir: 'images', file: 'laser.svg')}"/>
                <a href="https://www.hbz-nrw.de/produkte/digitale-inhalte/las-er" class="item" target="_blank">${message(code: 'landingpage.menu.about')}</a>
                <a class="item" href="https://wiki1.hbz-nrw.de/display/LAS/Startseite" target="_blank">Wiki</a>
                <g:link class="item" controller="gasco">${message(code:'menu.public.gasco_monitor')}</g:link>
                <div class="right item">
                    <g:link controller="home" action="index" class="ui button blue">
                        ${message(code: 'landingpage.login')}
                    </g:link>
                </div>
            </div>
        </div>
        <!-- HERO -->
        <div class="ui  masthead center aligned segment">
            <div class="ui container">

                <div class="ui grid ">
                    <div class="five wide column la-hero left aligned ">
                        <h1 class="ui inverted header ">
                            ${message(code: 'landingpage.hero.h1')}
                        </h1>
                        <h2 style="padding-bottom: 1rem;">
                            ${message(code: 'landingpage.hero.h2')}
                        </h2>

                        <a href="mailto:laser@hbz-nrw.de"  class="ui huge button">
                            ${message(code: 'landingpage.hero.button')}<i class="right arrow icon"></i>
                        </a>
                    </div>
                </div>
            </div>

        </div>

        <!-- NEWS -->
        <g:set var="systemMessages" value="${SystemMessage.getActiveMessages(SystemMessage.TYPE_STARTPAGE_NEWS)}" />

        <g:if test="${systemMessages}">
            <div class="ui segment la-eye-catcher">
                <div class="ui container">
                    <div class="ui labeled button" tabindex="0" >
                        <div class="ui blue button la-eye-catcher-header">
                            <h1>NEWS</h1>
                        </div>

                        <div class="ui basic blue left pointing label la-eye-catcher-txt">

                        <g:each in="${systemMessages}" var="news" status="i">
                            <div <g:if test="${i>0}">style="padding-top:1.6em"</g:if>>
                                <% println news.getLocalizedContent() %>
                            </div>
                        </g:each>

                        </div>
                    </div>
                </div>
            </div>
        </g:if>

%{--        <!-- segment -->
        <div class="ui segment">
            <div class="ui container">
                <div class="ui stackable grid">
                    <div class="four wide column">
                        <div class="la-feature">
                            <svg  xmlns="http://www.w3.org/2000/svg" viewBox="0 0 132.36 107.35"><defs><style>.cls-1{fill:#2d6696;}.cls-2{fill:#529bd0;}</style></defs><title>lizenzverhaltung</title><g id="Ebene_2" data-name="Ebene 2"><g id="Ebene_2-1" data-name="Ebene 2-1"><path class="cls-1" d="M16,4l0,.18a.82.82,0,0,0,.17.11c6.42,2.84,9.31,8,9.4,14.79.08,5.58,0,11.16,0,16.74q0,15.09,0,30.18,0,12.06,0,24.11a17.29,17.29,0,0,0,1.31,6.74,13.49,13.49,0,0,0,6.92,7.56,7.17,7.17,0,0,0,4.78.73c4.67-1.16,8.3-3.64,10.34-8.13a16.08,16.08,0,0,0,1.35-6.67.84.84,0,0,1,.94-.93H52c11.2,0,52.4-4,52.73-4v-.78q0-6.49,0-13,0-10.2,0-20.4v-36a17,17,0,0,0-2.27-8.76C99.92,2.31,96.34-.08,91.22,0,85.42.1,22.57,4,16,4Z"/><path class="cls-2" d="M43.4,107.34a47.22,47.22,0,0,0,4-2.65A14.5,14.5,0,0,0,52.68,94.6c.06-.55.1-1.11.12-1.67,0-.39.19-.53.56-.53.54,0,78.67-6,79-6,0,.57-.05,1.1-.11,1.63a15.79,15.79,0,0,1-5.43,10.81,10.82,10.82,0,0,1-7.24,2.62c-13.86,0-70.57,5.91-75.92,5.88Z"/><path class="cls-2" d="M22.8,19.93H0c.08-.85.12-1.63.24-2.39A15.57,15.57,0,0,1,5.75,7.37a10.52,10.52,0,0,1,4.5-2.19,2.91,2.91,0,0,1,1.1,0A14.34,14.34,0,0,1,22.83,19.37C22.83,19.52,22.82,19.67,22.8,19.93Z"/><path class="cls-2" d="M80.18,31.42a3.24,3.24,0,0,1-.76,1,2.71,2.71,0,0,1-1,.48A3.39,3.39,0,0,1,77,33c-.45-.07-.93-.15-1.45-.25a11.24,11.24,0,0,0-1.75-.16,8.16,8.16,0,0,0-2.22.29,6.75,6.75,0,0,0-3.24,1.63,3.23,3.23,0,0,0-1,2.33A1.37,1.37,0,0,0,68,38a6,6,0,0,0,1.87.72,24.81,24.81,0,0,0,2.64.45c1,.12,2,.26,3,.43a30,30,0,0,1,3.05.66,10.08,10.08,0,0,1,2.67,1.16,5.88,5.88,0,0,1,1.9,1.91,5.59,5.59,0,0,1,.76,2.9,10,10,0,0,1-1.06,4.6A12,12,0,0,1,79.31,55,6.26,6.26,0,0,1,81.49,57a5.67,5.67,0,0,1,.88,3.21,11.64,11.64,0,0,1-.8,4.42,13.23,13.23,0,0,1-2.54,4A18.28,18.28,0,0,1,74.79,72,24.65,24.65,0,0,1,69,74.49a19.21,19.21,0,0,1-3.31.66,21.76,21.76,0,0,1-3.2.12,13.81,13.81,0,0,1-2.85-.39A8.59,8.59,0,0,1,57.35,74l2.24-4.08a5,5,0,0,1,1-1.23A3.67,3.67,0,0,1,62,67.93a2.81,2.81,0,0,1,1.51-.06l1.49.35a10.32,10.32,0,0,0,1.93.23A9.47,9.47,0,0,0,69.78,68a7.71,7.71,0,0,0,3.14-1.59A3.12,3.12,0,0,0,74,64a1.94,1.94,0,0,0-.74-1.65,5,5,0,0,0-1.92-.82,15.7,15.7,0,0,0-2.7-.35c-1-.06-2-.14-3.09-.25a28.21,28.21,0,0,1-3.1-.49,8.16,8.16,0,0,1-2.69-1.08,5.71,5.71,0,0,1-1.9-2A6.74,6.74,0,0,1,57.17,54a9.69,9.69,0,0,1,1.19-4.59,12.3,12.3,0,0,1,3.64-4,6.56,6.56,0,0,1-2.18-2.26A7.41,7.41,0,0,1,59,39.37a10.67,10.67,0,0,1,.77-4,12.28,12.28,0,0,1,2.31-3.73,15.61,15.61,0,0,1,3.86-3.11,19.86,19.86,0,0,1,5.44-2.14,17.7,17.7,0,0,1,3.27-.51,15.41,15.41,0,0,1,3,.09,12.14,12.14,0,0,1,2.56.63,9.22,9.22,0,0,1,2,1.07ZM65.58,50.24a2,2,0,0,0,.75,1.63,5.38,5.38,0,0,0,1.94.89,18.78,18.78,0,0,0,2.75.48c1,.11,2.07.24,3.15.38a4.38,4.38,0,0,0,1.21-1.55,3.75,3.75,0,0,0,.35-1.61A1.92,1.92,0,0,0,75,48.84,5.54,5.54,0,0,0,73,48a20.35,20.35,0,0,0-2.73-.46c-1-.11-2-.26-3.08-.44A6,6,0,0,0,66,48.62,3.44,3.44,0,0,0,65.58,50.24Z"/></g></g></svg>
                        </div>
                        <h3 class="ui header">${message(code: 'landingpage.feature.1.head')}</h3>

                        <p><span
                                class="la-lead">${message(code: 'landingpage.feature.1.lead')}</span> ${message(code: 'landingpage.feature.1.bodycopy')}
                        </p>
                    </div>

                    <div class="four wide column">
                        <div class="la-feature">
                            <svg  xmlns="http://www.w3.org/2000/svg" viewBox="0 0 109.45 100.06"><defs><style>.cls-1{fill:#2d6696;}.cls-2{fill:#529bd0;}</style></defs><title>zugriffsstatistiken</title><g id="Ebene_3" data-name="Ebene 3"><g id="Ebene_3-1" data-name="Ebene 3-1"><path class="cls-1" d="M26.43,100c-1.54,0-3.61.61-3.91-2s1.59-2.89,3.36-3.34c2.92-.74,5.83-1.56,8.79-2.15,2.5-.49,3.9-1.63,4.14-4.36s1-5.72,1.43-8.59c.3-2,1.29-2.95,3.34-2.94q12.74,0,25.47,0c2.07,0,3,1.06,3.31,3,.46,3,1.1,5.93,1.49,8.92a3.89,3.89,0,0,0,3.52,3.76c3.39.69,6.72,1.66,10.08,2.51,1.69.43,2.84,1.3,2.61,3.27-.24,2.13-1.89,1.89-3.3,1.9C76.48,100.05,36.26,100.06,26.43,100Z"/><path class="cls-1" d="M54.62,73.22H6.3C1,73.22,0,72.32,0,67Q0,36.46,0,5.92C0,1.13,1.12,0,6,0q48.66,0,97.32,0c5.07,0,6.13,1.09,6.13,6.09q0,30.54,0,61.08c0,5.08-1,6-6.15,6q-24.33,0-48.66,0Z"/><rect class="cls-2" x="31.12" y="18.07" width="6.72" height="42.98" rx="3.36" ry="3.36"/><rect class="cls-2" x="43.2" y="34.86" width="6.72" height="26.19" rx="3.36" ry="3.36"/><rect class="cls-2" x="19.03" y="28.82" width="6.72" height="32.23" rx="3.36" ry="3.36"/><path class="cls-2" d="M88.33,6.66c-1.4,4.08-2.8,8.15-4.17,12.25-.44,1.33.34,1.41,1.3,1.25,4-.68,8.09-1.37,12.14-2A13.1,13.1,0,0,0,88.33,6.66Z"/><path class="cls-2" d="M81.61,24c-1,.16-1.74.07-1.3-1.26,1.37-4.09,2.77-8.17,4.17-12.25l.12,0a14.88,14.88,0,1,0,9,11.49C89.58,22.67,85.6,23.35,81.61,24Z"/></g></g></svg>
                        </div>
                        <h3 class="ui header">${message(code: 'landingpage.feature.2.head')}</h3>

                        <p><span
                                class="la-lead">${message(code: 'landingpage.feature.2.lead')}</span> ${message(code: 'landingpage.feature.2.bodycopy')}
                        </p>
                    </div>

                    <div class="four wide column">
                        <div class="la-feature">
                            <svg  xmlns="http://www.w3.org/2000/svg" viewBox="0 0 165.8 107.49"><defs><style>.cls-1{fill:#2d6696;}.cls-2{fill:#529bd0;}</style></defs><title>exportschnittstellen</title><g id="Ebene_4" data-name="Ebene 4"><g id="Ebene_4-1" data-name="Ebene 4-1"><path class="cls-1" d="M154.06,74.7V19.45a6.15,6.15,0,0,0-6.13-6.13H97.38a6.16,6.16,0,0,0-5.71,3.91v0c-.27.69-1.09,1.44-1.09,2.22V38.92a1.67,1.67,0,0,1-.79.08c-2.28-.16-5.66-.84-7.5-2.24a11.89,11.89,0,0,0-11.8-1.83A12.06,12.06,0,0,0,62.6,48.65a11.47,11.47,0,0,0,7.83,9.28,12,12,0,0,0,12.48-2.24c1.78-1.48,5.2-2.26,7.67-2.36V74.7c0,.79.82,1.54,1.1,2.24v0a6.14,6.14,0,0,0,5.7,3.89h50.55A6.15,6.15,0,0,0,154.06,74.7Z"/><path class="cls-2" d="M148.23,0c-1.82,1-3.56,2.08-5.34,3.05-7.27,4-13.21,7.92-20.48,11.87-3,1.65-6.08,3.27-9.1,5a3.65,3.65,0,0,0-1.53,5.06,3.69,3.69,0,0,0,5,1.51c3.35-1.75,5.31-3.57,8.63-5.38a10.16,10.16,0,0,0,1.09-.8l.88,2.27c-1,.57-2.24,1.27-3.47,1.94-4.69,2.54-8,5.06-12.74,7.6-2.87,1.56-3.39,4.55-1.15,6.51,1.24,1.07,2.83,1.14,4.69.14,2.59-1.39,5.17-2.81,7.76-4.22,3.12-1.7,4.9-3.41,8-5.11a6.92,6.92,0,0,1,.82-.31l.86,1.91c-.22.14-.5.34-.81.51-7,3.8-12.65,7.59-19.64,11.4a3.71,3.71,0,0,0,2,7,5.16,5.16,0,0,0,1.84-.63c6.67-3.61,12-7.25,18.65-10.87.5-.28,1-.52,1.74-.88l.94,2.06L123.24,47c-.89.48-.46,1-1.28,1.53a3.6,3.6,0,0,0-1.13,4.82c.86,1.56,1.57,2.35,3.3,1.58s3.62-1.85,5.41-2.82q9.83-5.31,19.64-10.66c.62-.33.86-.17,1.17.39,1.5,2.7,3.05,5.37,4.59,8,.09.15.21.28.37.49,2.07-3.38,4.11-6.68,6.13-10,1.41-2.29,2.83-4.57,4.18-6.9a1.81,1.81,0,0,0,0-1.46Q157.23,16.36,148.72.75C148.63.59,148.52.44,148.23,0Z"/><path class="cls-2" d="M87.58,57.41c-.27-.61-.47-.89-1.61.06a16.74,16.74,0,0,0-1.35,1.34A15.64,15.64,0,1,1,86,36.34a6.69,6.69,0,0,1,1.6.08V19.27a6.14,6.14,0,0,0-6.13-6.12H28.88a6.14,6.14,0,0,0-6.13,6.12V74.53a6.14,6.14,0,0,0,3.91,5.7h0a6.09,6.09,0,0,0,2.22.43H48.35a1.6,1.6,0,0,1,.09.78A11.29,11.29,0,0,1,46.2,87.6a11.89,11.89,0,0,0-1.84,11.8,12.06,12.06,0,0,0,13.72,7.89,11.47,11.47,0,0,0,9.29-7.82A12.06,12.06,0,0,0,65.13,87a10.08,10.08,0,0,1-2.34-6H81.27c3.69,0,6-3,6-6.71Z"/><path class="cls-1" d="M0,64.26c1.39-1.57,2.77-3.06,4.08-4.6q8.07-9.45,16.09-18.93c2.24-2.63,4.45-5.29,6.71-7.89a3.65,3.65,0,0,1,5.27-.46,3.69,3.69,0,0,1,.46,5.18c-2.4,2.92-4.87,5.78-7.32,8.66a9.6,9.6,0,0,1-1,.9l2,1.33c.77-.89,1.7-1.93,2.6-3,3.45-4.07,6.89-8.16,10.34-12.23,2.11-2.49,5.15-2.38,6.6.21.8,1.43.53,3-.82,4.62q-2.85,3.38-5.72,6.73c-2.31,2.71-4.62,5.41-6.92,8.13a5.63,5.63,0,0,0-.48.74l1.69,1.23a9,9,0,0,0,.67-.69Q42,45.1,49.75,36a3.71,3.71,0,0,1,6.48,3.38,5.14,5.14,0,0,1-1,1.67Q47.89,49.72,40.5,58.38c-.37.44-.72.9-1.21,1.53l1.82,1.34q5-5.93,10-11.82a25.84,25.84,0,0,1,2-2.26,3.59,3.59,0,0,1,4.95-.11,3.68,3.68,0,0,1,.59,4.86c-1.19,1.65-2.55,3.17-3.86,4.72q-7.22,8.53-14.46,17c-.46.54-.35.81.14,1.23,2.33,2,4.63,4.09,6.93,6.14a5.36,5.36,0,0,1,.41.46c-3.73,1.34-7.38,2.66-11,4-2.54.91-5.06,1.83-7.61,2.67a1.74,1.74,0,0,1-1.44-.25Q14.16,76.42.63,64.89C.49,64.77.38,64.64,0,64.26Z"/></g></g></svg>
                        </div>
                        <h3 class="ui header">${message(code: 'landingpage.feature.3.head')}</h3>

                        <p><span
                                class="la-lead">${message(code: 'landingpage.feature.3.lead')}</span> ${message(code: 'landingpage.feature.3.bodycopy')}
                        </p>
                    </div>

                    <div class="four wide column">
                        <div class="la-feature">
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 120.26 105.1"><defs><style>.cls-1{fill:#2d6696;}.cls-2{fill:#529bd0;}</style></defs><title>interaktion</title><g id="Ebene_5" data-name="Ebene 5"><g id="Ebene_5-1" data-name="Ebene 5-1"><path class="cls-1" d="M31,70a.88.88,0,0,1-.15-.84,9.37,9.37,0,0,0-.14-4,9.7,9.7,0,0,0-9.79-7.41,14.15,14.15,0,0,0-2.05.1A10,10,0,0,0,12,62.65a8.24,8.24,0,0,0-1.22,5.64c.09.6.33,1.33-.19,1.81-1.08,1-.68,2.1-.28,3.17a2.18,2.18,0,0,0,1.33,1.4,1.73,1.73,0,0,1,1.18,1.09c.31.58.6,1.18,1,1.72a8.85,8.85,0,0,0,7.13,4.35L22,81.67A8,8,0,0,0,26.73,79a14,14,0,0,0,2.55-3.91.62.62,0,0,1,.46-.37A3,3,0,0,0,31,70Z"/><path class="cls-1" d="M41.66,98.24c-.1-.67-.19-1.35-.3-2A15.3,15.3,0,0,0,37.52,88a20.61,20.61,0,0,0-8.58-5,1,1,0,0,0-1,.18,12.88,12.88,0,0,1-7,2.18,12.35,12.35,0,0,1-7.32-2.25A1.14,1.14,0,0,0,12.42,83a23.73,23.73,0,0,0-6.85,3.45A13.83,13.83,0,0,0,1.88,91,18.11,18.11,0,0,0,.15,96.88C0,98.11-.3,99.39.88,100.36a16,16,0,0,0,1.47,1.17,22.73,22.73,0,0,0,9.08,2.9,47.45,47.45,0,0,0,9.46.55c.47.3.93-.08,1.42,0a22.62,22.62,0,0,0,4.35-.21,48.18,48.18,0,0,0,8-1.42,15.82,15.82,0,0,0,5.47-2.38C41,100.29,41.87,99.56,41.66,98.24Z"/><path class="cls-1" d="M81.28,40.49c-.1-.67-.18-1.35-.3-2a15.3,15.3,0,0,0-3.84-8.22,20.5,20.5,0,0,0-8.58-5,1,1,0,0,0-1,.18,13,13,0,0,1-7,2.18,12.44,12.44,0,0,1-7.32-2.25,1.13,1.13,0,0,0-1.16-.08,23.94,23.94,0,0,0-6.86,3.46,13.72,13.72,0,0,0-3.69,4.53,18.38,18.38,0,0,0-1.73,5.87c-.16,1.24-.44,2.52.73,3.48A15,15,0,0,0,42,43.78a22.63,22.63,0,0,0,9.07,2.9,47.49,47.49,0,0,0,9.46.55c.47.3.93-.08,1.42,0a21.84,21.84,0,0,0,4.35-.2,49.24,49.24,0,0,0,8-1.42,16,16,0,0,0,5.47-2.38C80.6,42.53,81.49,41.81,81.28,40.49Z"/><path class="cls-1" d="M70.61,12.24a.88.88,0,0,1-.15-.84,9.36,9.36,0,0,0-.14-4A9.7,9.7,0,0,0,60.53,0a12.86,12.86,0,0,0-2.05.1A9.93,9.93,0,0,0,51.63,4.9a8.24,8.24,0,0,0-1.22,5.64c.09.59.33,1.33-.19,1.81-1.08,1-.68,2.1-.28,3.17a2.17,2.17,0,0,0,1.33,1.39A1.76,1.76,0,0,1,52.45,18c.31.58.6,1.18,1,1.72a8.84,8.84,0,0,0,7.13,4.34c.37-.05.75-.09,1.12-.15a8,8,0,0,0,4.69-2.66,14.1,14.1,0,0,0,2.55-3.91.65.65,0,0,1,.46-.38A3,3,0,0,0,70.61,12.24Z"/><path class="cls-1" d="M25.85,55.65a.45.45,0,0,0-.57.28l-.21.65a.46.46,0,0,0,.3.57l.13,0a.46.46,0,0,0,.44-.32c.06-.21.13-.42.2-.63A.45.45,0,0,0,25.85,55.65Z"/><path class="cls-1" d="M27.88,50.92a.46.46,0,0,0-.61.2l-.3.61a.46.46,0,0,0,.21.6.49.49,0,0,0,.2.05.46.46,0,0,0,.41-.26c.09-.2.19-.4.29-.59A.46.46,0,0,0,27.88,50.92Z"/><path class="cls-1" d="M33.29,42.65l-.47.49a.46.46,0,0,0,0,.64.42.42,0,0,0,.3.12.48.48,0,0,0,.34-.14l.45-.48a.45.45,0,1,0-.65-.63Z"/><path class="cls-1" d="M30,46.66l-.39.56a.44.44,0,0,0,.12.62.38.38,0,0,0,.25.08.45.45,0,0,0,.37-.19l.38-.55a.45.45,0,0,0-.1-.63A.46.46,0,0,0,30,46.66Z"/><path class="cls-1" d="M89.24,52.63a.45.45,0,0,0,.41.26.43.43,0,0,0,.19,0,.45.45,0,0,0,.22-.6c-.09-.2-.19-.41-.29-.61a.45.45,0,0,0-.6-.21A.44.44,0,0,0,89,52C89.06,52.23,89.15,52.43,89.24,52.63Z"/><path class="cls-1" d="M86.78,48.2a.46.46,0,0,0,.38.2.47.47,0,0,0,.25-.07.46.46,0,0,0,.13-.62l-.38-.57a.45.45,0,0,0-.75.51C86.54,47.83,86.66,48,86.78,48.2Z"/><path class="cls-1" d="M91,57.38a.46.46,0,0,0,.43.33.27.27,0,0,0,.13,0,.45.45,0,0,0,.31-.56c-.06-.21-.13-.43-.2-.65a.44.44,0,0,0-.56-.29.45.45,0,0,0-.3.56C90.89,57,91,57.17,91,57.38Z"/><path class="cls-1" d="M83.69,44.18a.45.45,0,0,0,.34.15.5.5,0,0,0,.3-.11.46.46,0,0,0,0-.64c-.15-.17-.3-.34-.46-.5a.44.44,0,0,0-.63,0,.44.44,0,0,0,0,.63Z"/><path class="cls-1" d="M66,99.92l-.64.14a.45.45,0,0,0-.35.53.44.44,0,0,0,.44.36h.09l.66-.14a.45.45,0,0,0-.2-.88Z"/><path class="cls-1" d="M61,100.67l-.66,0a.45.45,0,0,0,0,.9h0l.68-.05a.45.45,0,0,0,.41-.48A.45.45,0,0,0,61,100.67Z"/><path class="cls-1" d="M37.17,39.18l-.53.42a.45.45,0,0,0,.28.8.42.42,0,0,0,.28-.1l.52-.41a.45.45,0,0,0-.55-.71Z"/><path class="cls-1" d="M70.81,98.42c-.2.09-.41.16-.62.24a.46.46,0,0,0,.16.88l.16,0,.63-.25a.45.45,0,0,0,.26-.58A.47.47,0,0,0,70.81,98.42Z"/><path class="cls-1" d="M75.37,96.22l-.57.33a.45.45,0,0,0-.18.61.46.46,0,0,0,.4.23.59.59,0,0,0,.22,0l.59-.34a.44.44,0,0,0,.16-.61A.46.46,0,0,0,75.37,96.22Z"/><path class="cls-1" d="M46,98.44l-.62-.25a.45.45,0,0,0-.59.24A.45.45,0,0,0,45,99l.64.26a.45.45,0,0,0,.58-.26A.45.45,0,0,0,46,98.44Z"/><path class="cls-1" d="M41.43,96.23l-.57-.33a.45.45,0,0,0-.62.15.45.45,0,0,0,.16.62L41,97a.39.39,0,0,0,.23.07.48.48,0,0,0,.39-.23A.46.46,0,0,0,41.43,96.23Z"/><path class="cls-1" d="M55.87,100.68l-.66-.06a.46.46,0,0,0-.49.41.45.45,0,0,0,.41.49l.68.06h0a.45.45,0,0,0,.45-.42A.44.44,0,0,0,55.87,100.68Z"/><path class="cls-1" d="M50.86,99.93l-.65-.15a.44.44,0,0,0-.54.33.45.45,0,0,0,.33.54l.66.16h.1a.46.46,0,0,0,.44-.35A.45.45,0,0,0,50.86,99.93Z"/><path class="cls-2" d="M99.46,105c.47.3.93-.08,1.42,0a22.62,22.62,0,0,0,4.35-.21,48.18,48.18,0,0,0,8-1.42,15.82,15.82,0,0,0,5.47-2.38c.86-.65,1.76-1.38,1.55-2.7-.1-.67-.19-1.35-.3-2A15.3,15.3,0,0,0,116.09,88a20.61,20.61,0,0,0-8.58-5,1,1,0,0,0-1,.18,12.88,12.88,0,0,1-7,2.18,12.35,12.35,0,0,1-7.32-2.25A1.13,1.13,0,0,0,91,83a23.66,23.66,0,0,0-6.86,3.45A13.83,13.83,0,0,0,80.45,91a18.11,18.11,0,0,0-1.73,5.88c-.16,1.23-.44,2.51.73,3.48a16,16,0,0,0,1.47,1.17,22.73,22.73,0,0,0,9.08,2.9A47.49,47.49,0,0,0,99.46,105Z"/><path class="cls-1" d="M120.23,98.24c-.1-.67-.19-1.35-.3-2A15.3,15.3,0,0,0,116.09,88a20.61,20.61,0,0,0-8.58-5,1,1,0,0,0-1,.18,12.88,12.88,0,0,1-7,2.18,12.35,12.35,0,0,1-7.32-2.25A1.13,1.13,0,0,0,91,83a23.66,23.66,0,0,0-6.86,3.45A13.83,13.83,0,0,0,80.45,91a18.11,18.11,0,0,0-1.73,5.88c-.16,1.23-.44,2.51.73,3.48a16,16,0,0,0,1.47,1.17,22.73,22.73,0,0,0,9.08,2.9,47.49,47.49,0,0,0,9.46.55c.47.3.93-.08,1.42,0a22.62,22.62,0,0,0,4.35-.21,48.18,48.18,0,0,0,8-1.42,15.82,15.82,0,0,0,5.47-2.38C119.54,100.29,120.44,99.56,120.23,98.24Z"/><path class="cls-1" d="M109.56,70a.88.88,0,0,1-.15-.84,9.37,9.37,0,0,0-.14-4,9.7,9.7,0,0,0-9.79-7.41,14.15,14.15,0,0,0-2,.1,10,10,0,0,0-6.85,4.79,8.24,8.24,0,0,0-1.22,5.64c.09.6.33,1.33-.19,1.81-1.08,1-.68,2.1-.28,3.17a2.18,2.18,0,0,0,1.33,1.4,1.73,1.73,0,0,1,1.18,1.09c.31.58.6,1.18,1,1.72a8.85,8.85,0,0,0,7.13,4.35l1.12-.16A8,8,0,0,0,105.3,79a14,14,0,0,0,2.55-3.91.62.62,0,0,1,.46-.37A3,3,0,0,0,109.56,70Z"/><path class="cls-2" d="M42.66,86.19c-2-1.74-4-3.13-5.65-4.83-6-6.29-6.11-25.15-.37-31.69C41.1,44.59,47,42.18,53.44,41.1A35.24,35.24,0,0,1,75.18,44a23.26,23.26,0,0,1,7.89,6.1c5,6.08,5,24.41,0,30.44-4.27,5.06-9.94,7.71-16.3,8.78-3.43.57-7,.35-10.49.57a4,4,0,0,0-2.08.8,32.8,32.8,0,0,1-15.68,7c-.6.09-1.63-.17-1.83-.58a2.42,2.42,0,0,1,.43-1.93c1.59-2.39,3.31-4.7,4.9-7.09A7.66,7.66,0,0,0,42.66,86.19Z"/></g></g></svg>
                        </div>
                        <h3 class="ui header">${message(code: 'landingpage.feature.4.head')}</h3>

                        <p><span
                                class="la-lead">${message(code: 'landingpage.feature.4.lead')}</span> ${message(code: 'landingpage.feature.4.bodycopy')}
                        </p>
                    </div>
                </div>
            </div>
        </div>--}%

        <div class="ui center aligned segment">
            <a href="mailto:laser@hbz-nrw.de" class="ui huge blue button">
                ${message(code: 'landingpage.feature.button')}<i class="right arrow icon"></i>
            </a>
            <g:link controller="home" action="index" class="ui huge blue button">
                ${message(code: 'landingpage.login')}
                <i class="right arrow icon"></i>
            </g:link>
        </div>

        <g:render template="templates/footer" />


    </div>
</div>


    <script>
        $(document)
            .ready(function () {
                // fix menu when passed
                $('.masthead')
                    .visibility({
                        once: false,
                        onBottomPassed: function () {
                            $('.fixed.menu').transition('fade in');
                        },
                        onBottomPassedReverse: function () {
                            $('.fixed.menu').transition('fade out');
                        }
                    })
                ;

                // create sidebar and attach to menu open
                $('.ui.sidebar')
                    .sidebar('attach events', '.toc.item')
                ;
            })
        ;
    </script>

</body>
</html>