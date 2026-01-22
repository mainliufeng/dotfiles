import React from 'react';
import {
  AbsoluteFill,
  Sequence,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from 'remotion';

const COLORS = {
  bg: '#0B0F14',
  bgAlt: '#0F1722',
  text: '#F8FAFC',
  muted: '#94A3B8',
  accent: '#2DD4BF',
  accentSoft: '#5EEAD4',
  highlight: '#FBBF24',
  line: '#1F2937',
};

const TitleBlock: React.FC<{
  kicker?: string;
  title: string;
  subtitle?: string;
  align?: 'left' | 'center';
}> = ({kicker, title, subtitle, align = 'left'}) => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();
  const enter = spring({frame, fps, config: {damping: 200, mass: 0.8}});
  const opacity = interpolate(enter, [0, 1], [0, 1]);
  const translateY = interpolate(enter, [0, 1], [20, 0]);

  return (
    <div
      style={{
        textAlign: align,
        opacity,
        transform: `translateY(${translateY}px)`,
      }}
    >
      {kicker ? (
        <div
          style={{
            fontSize: 24,
            letterSpacing: 2,
            textTransform: 'uppercase',
            color: COLORS.accent,
            marginBottom: 12,
            fontWeight: 600,
          }}
        >
          {kicker}
        </div>
      ) : null}
      <div
        style={{
          fontSize: 72,
          fontWeight: 700,
          lineHeight: 1.05,
          color: COLORS.text,
        }}
      >
        {title}
      </div>
      {subtitle ? (
        <div
          style={{
            marginTop: 16,
            fontSize: 30,
            lineHeight: 1.4,
            color: COLORS.muted,
            maxWidth: align === 'center' ? 900 : 980,
          }}
        >
          {subtitle}
        </div>
      ) : null}
    </div>
  );
};

const BulletList: React.FC<{items: string[]; startDelay?: number}> = ({
  items,
  startDelay = 0,
}) => {
  return (
    <div style={{display: 'flex', flexDirection: 'column', gap: 18}}>
      {items.map((item, index) => (
        <Bullet key={item} index={index} delay={startDelay} text={item} />
      ))}
    </div>
  );
};

const Bullet: React.FC<{text: string; index: number; delay: number}> = ({
  text,
  index,
  delay,
}) => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();
  const localFrame = Math.max(0, frame - delay - index * 6);
  const enter = spring({frame: localFrame, fps, config: {damping: 200}});
  const opacity = interpolate(enter, [0, 1], [0, 1]);
  const translateX = interpolate(enter, [0, 1], [24, 0]);

  return (
    <div
      style={{
        display: 'flex',
        alignItems: 'center',
        gap: 16,
        opacity,
        transform: `translateX(${translateX}px)`,
      }}
    >
      <div
        style={{
          width: 10,
          height: 10,
          borderRadius: 999,
          background: COLORS.accent,
          boxShadow: `0 0 12px ${COLORS.accent}`,
          flexShrink: 0,
        }}
      />
      <div style={{fontSize: 30, color: COLORS.text}}>{text}</div>
    </div>
  );
};

const CommandCard: React.FC<{title: string; commands: string[]}> = ({
  title,
  commands,
}) => {
  return (
    <div
      style={{
        background: 'rgba(15, 23, 34, 0.9)',
        border: `1px solid ${COLORS.line}`,
        borderRadius: 20,
        padding: '26px 32px',
        boxShadow: '0 20px 60px rgba(2, 6, 23, 0.6)',
      }}
    >
      <div
        style={{
          fontSize: 22,
          color: COLORS.accentSoft,
          textTransform: 'uppercase',
          letterSpacing: 2,
          marginBottom: 18,
        }}
      >
        {title}
      </div>
      <div style={{display: 'flex', flexDirection: 'column', gap: 14}}>
        {commands.map((cmd) => (
          <div
            key={cmd}
            style={{
              fontSize: 26,
              fontFamily: 'ui-monospace, SFMono-Regular, Menlo, Monaco, monospace',
              color: COLORS.text,
              background: 'rgba(15, 23, 42, 0.7)',
              borderRadius: 12,
              padding: '12px 16px',
            }}
          >
            {cmd}
          </div>
        ))}
      </div>
    </div>
  );
};

const SceneFrame: React.FC<{children: React.ReactNode}> = ({children}) => {
  return (
    <AbsoluteFill
      style={{
        padding: '110px 140px',
        justifyContent: 'center',
      }}
    >
      {children}
    </AbsoluteFill>
  );
};

const Background: React.FC = () => {
  const frame = useCurrentFrame();
  const drift = interpolate(frame, [0, 600], [0, 80]);

  return (
    <AbsoluteFill
      style={{
        background: `radial-gradient(circle at 20% 20%, #1F2937 0%, ${COLORS.bg} 45%), radial-gradient(circle at 80% 10%, rgba(45, 212, 191, 0.18) 0%, rgba(11, 15, 20, 0.1) 55%), ${COLORS.bg}`,
      }}
    >
      <div
        style={{
          position: 'absolute',
          top: -120 + drift,
          left: -60,
          width: 360,
          height: 360,
          borderRadius: '50%',
          background: 'rgba(45, 212, 191, 0.12)',
          filter: 'blur(40px)',
        }}
      />
      <div
        style={{
          position: 'absolute',
          bottom: -160,
          right: -40,
          width: 420,
          height: 420,
          borderRadius: '50%',
          background: 'rgba(251, 191, 36, 0.12)',
          filter: 'blur(50px)',
        }}
      />
      <div
        style={{
          position: 'absolute',
          top: 80,
          right: 120,
          width: 240,
          height: 140,
          borderRadius: 24,
          border: `1px solid ${COLORS.line}`,
          background: 'rgba(15, 23, 34, 0.6)',
        }}
      />
    </AbsoluteFill>
  );
};

export const HyprlandSkillIntro: React.FC = () => {
  return (
    <AbsoluteFill style={{fontFamily: '"Noto Sans", "PingFang SC", "Microsoft YaHei", sans-serif'}}>
      <Background />

      <Sequence from={0} durationInFrames={120}>
        <SceneFrame>
          <TitleBlock
            kicker="Skill Intro"
            title="Hyprland Skill 快速入门"
            subtitle="用 hyprctl 脚本化工作区与窗口布局，让桌面管理变成可复用工作流。"
          />
        </SceneFrame>
        <div
          style={{
            position: 'absolute',
            bottom: 90,
            left: 140,
            padding: '10px 20px',
            borderRadius: 999,
            background: 'rgba(45, 212, 191, 0.15)',
            color: COLORS.accentSoft,
            fontSize: 20,
            letterSpacing: 1,
          }}
        >
          dotfiles / hyprland
        </div>
      </Sequence>

      <Sequence from={120} durationInFrames={120}>
        <SceneFrame>
          <div style={{display: 'flex', gap: 60, alignItems: 'center'}}>
            <div style={{flex: 1}}>
              <TitleBlock
                kicker="Quick Start"
                title="三条命令启动工作区"
                subtitle="一键创建、打开项目布局、定制终端组合。"
              />
              <div style={{marginTop: 36}}>
                <BulletList
                  items={[
                    '创建命名 workspace 并切换',
                    '打开 Codex + Shell + Neovim 标准布局',
                    '自定义多个终端标签与命令',
                  ]}
                  startDelay={10}
                />
              </div>
            </div>
            <div style={{flex: 0.9}}>
              <CommandCard
                title="核心脚本"
                commands={[
                  'scripts/hypr-ws-create.sh <name>',
                  'scripts/hypr-ws-open-project.sh [project|path]',
                  'scripts/hypr-ws-open-terms.sh <ws> <dir> ...',
                ]}
              />
            </div>
          </div>
        </SceneFrame>
      </Sequence>

      <Sequence from={240} durationInFrames={120}>
        <SceneFrame>
          <TitleBlock
            kicker="Workspace Flow"
            title="把项目启动流程固化"
            subtitle="支持默认项目根目录、自动命名 workspace、以及一组可覆盖的环境变量。"
          />
          <div style={{marginTop: 40, maxWidth: 1100}}>
            <BulletList
              items={[
                '默认项目根：~/Code/self 与 ~/Code/rcrai',
                'workspace 名称自动取 repo basename',
                'HYPR_WORKSPACE_* 环境变量覆盖终端、Shell、Codex 参数',
              ]}
            />
          </div>
        </SceneFrame>
      </Sequence>

      <Sequence from={360} durationInFrames={120}>
        <SceneFrame>
          <div style={{display: 'grid', gridTemplateColumns: '1.1fr 0.9fr', gap: 50}}>
            <div>
              <TitleBlock
                kicker="Window Control"
                title="窗口管理脚本化"
                subtitle="聚焦、移动、浮动、缩放，一条命令完成。"
              />
              <div style={{marginTop: 36}}>
                <BulletList
                  items={[
                    '按 class / title 规则聚焦窗口',
                    '一键移动到指定 workspace',
                    '浮动、居中、精确 resize',
                    'wofi 选择窗口 & 列出 clients',
                  ]}
                />
              </div>
            </div>
            <CommandCard
              title="常用操作"
              commands={[
                'scripts/hypr-win-focus.sh --class REGEX --title REGEX',
                'scripts/hypr-win-move.sh <workspace> [--follow]',
                'scripts/hypr-win-float.sh --size 1300x800 --center',
                'scripts/hypr-list-clients.sh',
              ]}
            />
          </div>
        </SceneFrame>
      </Sequence>

      <Sequence from={480} durationInFrames={120}>
        <SceneFrame>
          <TitleBlock
            kicker="Next Steps"
            title="让 Hyprland 变成自动化工作流"
            subtitle="从脚本开始，逐步把你的窗口编排写成可复用的操作。"
            align="center"
          />
          <div
            style={{
              marginTop: 50,
              display: 'flex',
              justifyContent: 'center',
              gap: 28,
              flexWrap: 'wrap',
            }}
          >
            {['复制脚本', '运行命令', '调整变量', '沉淀习惯'].map((step, index) => (
              <StepTag key={step} index={index} label={step} />
            ))}
          </div>
        </SceneFrame>
      </Sequence>
    </AbsoluteFill>
  );
};

const StepTag: React.FC<{label: string; index: number}> = ({label, index}) => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();
  const local = Math.max(0, frame - index * 8);
  const enter = spring({frame: local, fps, config: {damping: 160}});
  const opacity = interpolate(enter, [0, 1], [0, 1]);
  const translateY = interpolate(enter, [0, 1], [18, 0]);

  return (
    <div
      style={{
        padding: '14px 26px',
        borderRadius: 999,
        background: 'rgba(15, 23, 42, 0.7)',
        border: `1px solid ${COLORS.line}`,
        color: COLORS.text,
        fontSize: 24,
        opacity,
        transform: `translateY(${translateY}px)`,
      }}
    >
      {label}
    </div>
  );
};
