
@echo off
cd /d %~dp0
setlocal ENABLEDELAYEDEXPANSION

REM =================================================================
REM�@�V�X�e�������W�o�b�`���Ăяo��
REM =================================================================

REM -------------------------------------------------------------------------------------
REM�@�����i�ꊇ�Ăяo�����Ɏw�肳�����́j
REM�@�@%1�F ���s���[�h�BAUTO�Ŏ������[�h(���C�������I�����̃��b�Z�[�W�o�͂�pause�����Ȃ�����)
REM�@�@%2�F ���ʂ��i�[����t�@�C�����B�e�L�X�g�t�@�C��(*.txt)�̂ݎw��B
REM�@�@%3�F �o�̓��[�h�BFULL,NORMAL,SIMPLE,CPUZ_BENCH,X264BENCH�̂����ꂩ�B
REM�@�@%4�F ���O�擾���[�h�BRECYCLE�̏ꍇ��CPU-Z�ɂ��V�K���O�擾�͍s�킸�������O�𗘗p����B
REM -------------------------------------------------------------------------------------

call _Env1__�V�X�e�����̃t���擾�����s�������ꍇ�͂�����_�u���N���b�N.bat MANUAL "" SIMPLE

IF NOT %ERRORLEVEL%==0 (
 exit /b %ERRORLEVEL%
)